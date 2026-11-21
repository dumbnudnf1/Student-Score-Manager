# 数学成绩管理系统 · 联网版部署说明（Wasmer Edge + 你已有的托管 MySQL）

> 支持：账号密码登录（登录/注册老师/注册学生三入口）、数据存 MySQL、多班级多学科、老师/学生均可加入多个班级、老师可读写+发消息、学生只读、手机电脑都能访问。
> 只想在本机双击打开、不要账号的话，继续用根目录的「数学成绩管理系统-双击打开.html」（单机版）。

---

## 一、你的数据库信息（已按截图配置好，无需再填）

你在 Wasmer 后台已经建好了一个 MySQL 数据库，截图里显示的连接信息是：

| 项目 | 值 |
| --- | --- |
| 数据库名 | `db_8f1ca36c4` |
| Host | `db.fr-xoub1.bengt.wasmernet.com` |
| Port | `20194` |
| 用户名 | `user_987fb6ca` |
| 密码 | **不在本文件、代码或任何项目文件中保存** |

**关键机制**：Wasmer 会在应用运行时，把上面这些信息通过环境变量 `DB_HOST / DB_PORT / DB_NAME / DB_USERNAME / DB_PASSWORD` 自动注入给应用。服务端代码已经写好读取这些变量（并且兼容 `DB_USERNAME`），所以：

- ✅ 你**不需要**把数据库密码填到项目任何文件里；
- ✅ 我**没有**把你的密码写进代码、文档或配置（避免泄露）；
- ✅ 应用部署到 Wasmer 后，会自动用这套信息连上数据库、自动建表。

> 如需修改密码，请在 Wasmer 后台点数据库的「Rotate credentials / 轮换凭据」，应用无需改动，下一次部署自动用新凭据。

---

## 二、整体结构（30 秒看懂）

```
手机 / 电脑浏览器
      ↓ https://你的应用.wasmer.app
Wasmer Edge（运行 Node.js 后端 + 网页）
      ↓ 用平台注入的 DB_* 环境变量连接
你的托管 MySQL（db_8f1ca36c4，存账号 / 班级 Code / 成绩快照）
```

---

## 三、第一次部署（约 10 分钟）

### 3.1 安装并登录 Wasmer 命令行

在本机用 Git Bash 或 WSL 执行：

```bash
curl https://get.wasmer.io -sSfL | sh
wasmer login
```

### 3.2 修改 `app.yaml` 的两处名字（★关键：决定连哪个数据库）

用记事本打开项目根目录的 `app.yaml`：

```yaml
owner: 你的Wasmer用户名       # ← 改成你的 Wasmer 账号名
name: math-score-manager      # ← 应用名；被占用就换，如 math-score-andy
```

> ★ **非常重要 —— 数据库是"挂在某个应用下面"的，一个应用只有一个数据库。**
> 你截图里的 `db_8f1ca36c4` 属于 Wasmer 后台里的某一个应用。要让网站连到**这个**库，
> 必须用**同一个应用**来部署：也就是说这里的 `owner` + `name` 要和你在 Wasmer 后台建数据库时
> 所在的那个应用完全一致。
> - 怎么确认：打开 Wasmer 后台 → 你的应用列表 → 找到 Databases 页里显示 `db_8f1ca36c4` 的那个应用，
>   它的账号名就是 `owner`，应用名就是 `name`。照原样填，不要另起新名字。
> - 如果填了全新的应用名，Wasmer 会**新建一个空数据库**给新应用，网站功能一样能用，但数据是空的、
>   不是你截图里那个库。首次使用其实空库更干净；只有你想沿用旧库里的数据时才需要严格对应。

其余内容不用动：
- `capabilities.database: engine: mysql` 表示这个应用使用 MySQL 数据库：已有就复用、没有就在首次部署时自动创建；
- 平台会把该库的 `DB_HOST/DB_PORT/DB_NAME/DB_USERNAME/DB_PASSWORD` 自动注入，服务端已开启 TLS（私有 CA，不校验证书链），无需手填密码；
- `env.JWT_SECRET` 已经生成好随机值，开箱即用；
- `/api/health` 是健康检查，**并且会真实执行一条 SQL 验证数据库连通性**，应用异常会自动重启。

### 3.3 部署

在项目根目录执行：

```bash
wasmer deploy --build-remote
```

按提示选 owner / app 名称。成功后命令行会显示网址，例如：

```
https://math-score-andy-你的用户名.wasmer.app
```

**这个网址所有人都能打开**，不需要你电脑开机或运行任何程序。

### 3.4 验证是否正常（自检数据库是否真的连上）

浏览器打开你的网址，应看到登录页。再访问 `你的网址/api/health`：

**✅ 连接正常**（HTTP 200）——注意 `db.connected` 为 `true`，这是**真的执行了一条 SQL** 后的结果，代表数据库能连上、能读写：

```json
{"ok":true,"mode":"mysql","allowRegister":true,"classCodeJoin":true,"db":{"connected":true,"mode":"mysql","detail":"db.fr-xoub1.bengt.wasmernet.com:20194/db_8f1ca36c4"},"time":"..."}
```

**❌ 连接异常**（HTTP 503）——`db.connected` 为 `false`，`detail` 里是错误原因：

```json
{"ok":false,"mode":"mysql","db":{"connected":false,"detail":"……错误信息……"}}
```

排查顺序：
1. 确认数据库已附加到这个应用（Wasmer 后台 → 你的应用 → Databases 页能看到那张库卡片）；
2. 去 App → Logs 看启动日志，是否有数据库连接/建表报错；
3. 确认 `app.yaml` 里 `DB_DRIVER: "mysql"` 在、且 `capabilities.database: engine: mysql` 没被删；
4. 凭据若轮换过无需改代码，重新部署一次即可（或等平台自动更新注入变量）。

只要 `/api/health` 返回 200 且 `db.connected:true`，就等于"网站已正常连上你的云端数据库，可以存取数据了"。

---

## 四、老师使用流程

1. 打开网站 → 「注册老师」→ 填账号 / 密码 / 称呼（**不需要班级 Code**）。
2. 进入「我的班级」→「＋ 创建班级」→ 填班级名和学科 → 系统生成 6 位加入码。
3. 进入该班级 →「初始化设置」配满分、录学生名单 → 数据自动存到 MySQL，顶栏显示「✓ 已保存」。
4. 在「我的班级」复制班级加入码发给学生；创建者可重置加入码（设置 → 班级加入码 也可统一管理）。
5. 老师可以用别人的 Code「加入班级」共同管理，也可创建多个班级，顶部下拉随时切换。
6. 「班级消息」里向当前班级发布通知，学生可见。
7. 若之前用单机版录过数据：导出 JSON 后，进入目标班级在「设置与备份 → 备份与恢复」导入。

---

## 五、学生使用流程

1. 打开网站 → 点「**注册学生**」→ 填账号 / 密码 / 姓名（**注册时不需要班级 Code**）。
2. 进入「我的班级」→「＋ 加入班级」→ 输入老师给的 **6 位班级 Code**。
3. 可加入**多个班级**（如不同学科），顶部下拉切换当前班级。
4. 对自己加入的每个班级**只能查看、不能修改**：
   - 侧栏只有查看类菜单；改名、排序、增删按钮均隐藏；
   - 手动改地址栏访问管理页也会被拦截；
   - 服务端再次校验角色，学生账号写请求一律拒绝（403）。
5. 「班级消息」可看到**所有已加入班级**的通知（每条标注班级名）。

---

## 六、本地运行（不部署时，仅本机试用）

```bash
cp server/.env.example server/.env
# 先保持 DB_DRIVER=file，无需数据库
双击「启动服务器-本地模式.bat」
浏览器访问 http://localhost:8790
```

**注意**：你现在的数据库域名 `db.fr-xoub1.bengt.wasmernet.com` 是 Wasmer **内网域名**，只有部署在 Wasmer 上才能解析；在自己电脑上填它连 MySQL 会报 `ENOTFOUND`，这是正常的，不是配置错误。本地想连数据库请用自己的公网 MySQL 或直接用 file 模式。

数据表（users / classes / memberships / class_data / messages）会在首次以 mysql 模式启动时自动创建，无需手动建表。数据按班级隔离：一个班级一份数据包，老师/学生通过「成员关系」加入班级，一个账号可加入多个班。

---

## 七、安全检查清单

- [x] 数据库密码**未**写入任何项目文件（由平台运行时注入）
- [x] 服务端已兼容 `DB_USERNAME`（Wasmer 注入的变量名）
- [x] `app.yaml` 已配好 `capabilities.database` 复用你的数据库
- [x] `JWT_SECRET` 已生成随机值（正式使用建议用 secrets 覆盖，见下）
- [x] 学生账号服务端强制只读（按班级过滤数据，写请求 403）
- [x] 数据按班级隔离：成员关系校验，未加入的班级读不到
- [x] 注册无需班级 Code；登录后由老师/学生分别创建或加入班级
- [ ] 部署前把 `app.yaml` 的 `owner` 和 `name` 改成你自己的

如需更稳妥地管理密钥，可在 Wasmer 后台 App → Settings → Secrets 添加 `JWT_SECRET`（同名 secret 优先于 `app.yaml` 里的值），然后重新部署。详见 <https://docs.wasmer.io/edge/learn/secrets>。

---

## 八、常见问题

**Q：部署后打不开 / 显示错误？**
A：在 Wasmer 后台 App → Logs 看日志。常见原因：owner 写错、数据库没附加到应用。

**Q：`/api/health` 的 mode 不是 mysql？**
A：检查 `app.yaml` 里 `DB_DRIVER: "mysql"` 是否在，以及数据库是否已连接到这个应用。

**Q：注册老师被拒绝？**
A：`ALLOW_REGISTER` 默认是 `true`。学生注册不受此限制。

**Q：学生看不到成绩？**
A：确认学生已在「我的班级」用有效 Code 加入对应班级，且老师已在该班录入并保存过数据。注册时填的姓名若与名册一致，会自动关联本人档案。

**Q：班级 Code 在哪？**
A：老师登录后 →「我的班级」每张班级卡片上；或设置与备份 → 班级加入码。

**Q：一个账号能加入多个班级吗？**
A：可以。老师和学生都能凭 Code 加入多个班级，用顶部下拉框切换当前班级，数据互不干扰。

**Q：学生能改成绩或发消息吗？**
A：不能。学生全程只读，服务端强制拦截写请求；只有老师能改数据、发消息。

**Q：数据会丢吗？**
A：数据存在托管 MySQL，不会因清理浏览器丢失。仍建议定期在「设置与备份 → 备份与恢复」导出 JSON 留底。

---

## 九、文件说明

```
app.yaml                           ← Wasmer Edge 应用配置（复用托管数据库 + 健康检查）
Anybuild                           ← Wasmer 远程构建配置（Node 24 + npm）
dist/index.html                    ← 联网版网页（由后端托管）
server/index.js                    ← 后端服务与 API
server/storage.js                  ← MySQL / 本地文件双存储（用户/班级/成员/数据/消息）
server/dataFilter.js               ← 学生按班级只读过滤
server/config.js                   ← 读取平台注入的 DB_* 环境变量
server/.env.example                ← 本地配置模板（不含任何真实密码）
启动服务器-云数据库.bat            ← 本地连自己的 MySQL 启动
启动服务器-本地模式.bat            ← 本地免数据库试用
数学成绩管理系统-双击打开.html      ← 单机版（不登录，双击即用）
```
