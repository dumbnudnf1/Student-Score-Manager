@echo off
chcp 65001 >nul
title 数学成绩管理系统 - 本地模式服务器
cd /d "%~dp0"

echo.
echo  ============================================
echo   数学成绩管理系统 - 本地模式（无需云数据库）
echo  ============================================
echo.
echo  数据保存在服务器本地文件 server\data.json
echo  适合先试用。手机连同一个 WiFi 也能访问。
echo.

set DB_DRIVER=file
set PORT=8790
if "%JWT_SECRET%"=="" set JWT_SECRET=local-dev-secret-change-me-2026

echo  正在启动服务器，请保持此窗口开启...
echo  浏览器将自动打开 http://localhost:8790
echo.
start "" http://localhost:8790
node server/index.js

echo.
echo  服务器已停止。按任意键关闭窗口。
pause >nul
