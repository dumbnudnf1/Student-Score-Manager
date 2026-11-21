# 安装 Wasmer 命令行（Windows 手把手版）

> 装这个命令行，是为了在项目文件夹里执行一条 `wasmer deploy`，把网站部署到网上、连上你的云端数据库。
> 全程复制粘贴即可，不用担心输错。下面的 `Vasmir / Wasmer` 指的是同一个东西（正确拼写是 **Wasmer**）。

---

## 第 0 步：先确认你的系统

你是 **Windows**，所以照着「Windows 方式」做即可。文末也附了 Mac / Linux 的命令，备用。

---

## 第 1 步：打开 PowerShell（2 分钟）

1. 按键盘上的 `Win` 键（Windows 徽标键）。
2. 直接输入 `powershell`。
3. 在搜索结果里点「**Windows PowerShell**」（或按回车）。

会弹出一个蓝色窗口，这就是命令行窗口，后面的命令都粘贴到这里执行。

> 粘贴方法：复制命令 → 在窗口里**点一下鼠标** → 按 `Ctrl + V` → 按回车。

---

## 第 2 步：安装 Wasmer（核心，1 分钟）

在 PowerShell 里粘贴下面这一整行，然后回车：

```powershell
iwr https://win.wasmer.io -useb | iex
```

它会自动下载并安装。看到安装完成的提示就成功了。

### 如果报错："无法加载文件 ... 因为在此系统上禁止运行脚本"

这是 Windows 的默认安全限制，**先粘贴这一行回车**：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

提示是否更改时输入 `Y` 回车，然后再重新执行第 2 步的安装命令。

---

## 第 3 步：让它生效（重要，别跳过）

安装程序会把 `wasmer` 加入系统路径，但**当前窗口还认不出来**。所以：

- **关掉 PowerShell 窗口，重新打开一个新的**（第 1 步的方法）。

然后粘贴这一行验证：

```powershell
wasmer --version
```

如果能显示出一个版本号（类似 `wasmer 7.x.x`），就说明**安装成功**。

> 如果提示"无法将 wasmer 识别为 cmdlet/命令"：
> - 先确认你**重开了新窗口**；
> - 还不行就重启一下电脑，再试 `wasmer --version`。

---

## 第 4 步：登录你的 Wasmer 账号

在新开的 PowerShell 里粘贴：

```powershell
wasmer login
```

它通常会**自动打开浏览器**，让你登录或授权：
- 有账号就登录；没有就先去 <https://wasmer.io/signup> 注册（免费）。
- 在浏览器里完成授权后，回到 PowerShell，看到登录成功的提示即可。

---

## 第 5 步（可选）：更新到最新版

Wasmer 更新很快，如果之前装过旧版，可以执行：

```powershell
wasmer self-update
```

---

## ✅ 装好了，下一步做什么？

命令行装好并登录后，回到**项目文件夹**（就是有 `app.yaml` 的那个文件夹）：

1. 用记事本打开 `app.yaml`，把 `owner` 和 `name` 改成你自己的（详见《README-联网版部署说明.md》第 3.2 节）。
2. 在 PowerShell 里进入这个文件夹（把下面路径换成你自己项目的实际路径）：

   ```powershell
   cd "C:\Users\admin\WorkBuddy\2026-11-20-15-40-31"
   ```

3. 执行部署：

   ```powershell
   wasmer deploy
   ```

4. 按提示选择 owner / 应用名（或者直接认出 `app.yaml` 里的配置）。部署完成后会给出一个 `https://....wasmer.app` 网址。
5. 打开 `你的网址/api/health`，看到 `db.connected:true` 就说明网站已连上你的云端数据库，可以正常用了。

---

## 附：Mac / Linux 安装命令（备用，你用不到可跳过）

在终端（Terminal）执行：

```bash
curl https://get.wasmer.io -sSfL | sh
```

验证：`wasmer --version`　登录：`wasmer login`　更新：`wasmer self-update`

> Windows 上如果装了 Git Bash 或 WSL，也可以用上面这条 Bash 命令，效果一样。

---

## 常见问题速查

| 现象 | 解决办法 |
|---|---|
| 提示"禁止运行脚本" | 先执行 `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`，再装 |
| `wasmer` 认不出来 | 关掉窗口重开；还不行就重启电脑 |
| 登录时浏览器没自动打开 | 按提示复制显示的网址，手动粘到浏览器打开 |
| 不知道自己在哪个文件夹 | 在 PowerShell 执行 `pwd` 会显示当前路径；用 `cd "路径"` 切换 |
| 想确认是否已登录 | 执行 `wasmer app list`，能列出应用（哪怕是空的）就是已登录 |

官方安装文档：<https://docs.wasmer.io/install>
