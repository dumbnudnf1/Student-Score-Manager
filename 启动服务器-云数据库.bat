@echo off
chcp 65001 >nul
title 数学成绩管理系统 - 云数据库模式
cd /d "%~dp0"

echo.
echo  ============================================
echo   数学成绩管理系统 - 云数据库模式
echo  ============================================
echo.
echo  启动前请确认已配置 server\.env 里的数据库连接信息：
echo    DB_HOST / DB_PORT / DB_USER / DB_PASSWORD / DB_NAME
echo.

if not exist "server\.env" (
  echo  [错误] 找不到 server\.env 配置文件！
  echo  请把 server\.env.example 复制为 server\.env 并填写数据库信息。
  echo.
  pause
  exit /b 1
)

echo  正在启动服务器，请保持此窗口开启...
echo  浏览器将自动打开 http://localhost:8790
echo.
start "" http://localhost:8790
node server/index.js

echo.
echo  服务器已停止（如提示数据库错误，请检查 server\.env）。按任意键关闭。
pause >nul
