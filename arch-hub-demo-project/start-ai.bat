@echo off
REM Starts the local AI that Arch Hub uses: llama.cpp model servers plus the response gateway.
REM Nothing leaves this computer.

set "LLAMA_DIR=C:\Users\HP\Tools\llama-dl"
set "MODELS=C:\Users\HP\Models"
set "VL_MODEL=%MODELS%\Qwen3VL-2B-Instruct-Q4_K_M.gguf"
set "VL_PROJ=%MODELS%\mmproj-Qwen3VL-2B-Instruct-Q8_0.gguf"
set "TEXT_MODEL=%MODELS%\qwen2.5-1.5b-instruct-q4_k_m.gguf"
set "GATEWAY=C:\Users\HP\Documents\Codex\2026-10-17\yo\outputs\response-gateway"

if not exist "%LLAMA_DIR%\llama-server.exe" (
  echo llama-server.exe was not found in %LLAMA_DIR%
  echo Download the llama.cpp Windows CPU build into that folder first.
  pause & exit /b 1
)

REM The text model answers quickly; the vision model reads site photos.
set "PRIMARY="
set "PRIMARY_NAME="
if exist "%TEXT_MODEL%" (
  set "PRIMARY=%TEXT_MODEL%"
  set "PRIMARY_NAME=qwen2.5-1.5b-instruct"
)
if not defined PRIMARY if exist "%VL_MODEL%" if exist "%VL_PROJ%" (
  set "PRIMARY=%VL_MODEL%"
  set "PRIMARY_NAME=qwen3-vl-2b-instruct"
)
if not defined PRIMARY (
  echo No usable model found in %MODELS%
  pause & exit /b 1
)

set "VISION_URL="
if exist "%VL_MODEL%" if exist "%VL_PROJ%" (
  if "%PRIMARY_NAME%"=="qwen3-vl-2b-instruct" ( set "VISION_URL=http://127.0.0.1:8080/v1" ) else ( set "VISION_URL=http://127.0.0.1:8081/v1" )
)

curl -s -m 3 http://127.0.0.1:8080/v1/models | find "qwen" >nul
if errorlevel 1 (
  echo Starting the %PRIMARY_NAME% server on http://127.0.0.1:8080 ...
  if "%PRIMARY_NAME%"=="qwen3-vl-2b-instruct" (
    start "Arch Hub model" /min "%LLAMA_DIR%\llama-server.exe" -m "%PRIMARY%" --mmproj "%VL_PROJ%" --alias "%PRIMARY_NAME%" --host 127.0.0.1 --port 8080 -c 8192
  ) else (
    start "Arch Hub model" /min "%LLAMA_DIR%\llama-server.exe" -m "%PRIMARY%" --alias "%PRIMARY_NAME%" --host 127.0.0.1 --port 8080 -c 4096
  )
  timeout /t 25 /nobreak >nul
) else (
  echo Model server on 8080 already running.
)

if not "%PRIMARY_NAME%"=="qwen3-vl-2b-instruct" if defined VISION_URL (
  curl -s -m 3 http://127.0.0.1:8081/v1/models | find "qwen" >nul
  if errorlevel 1 (
    echo Starting the photo analysis server on http://127.0.0.1:8081 ...
    start "Arch Hub vision" /min "%LLAMA_DIR%\llama-server.exe" -m "%VL_MODEL%" --mmproj "%VL_PROJ%" --alias qwen3-vl-2b-instruct --host 127.0.0.1 --port 8081 -c 8192 -t 8
    timeout /t 30 /nobreak >nul
  ) else (
    echo Photo analysis server already running.
  )
)

cd /d "%GATEWAY%" || (echo Gateway folder missing.& pause & exit /b 1)
set "AI_BACKEND=llama"
set "LLAMA_URL=http://127.0.0.1:8080/v1"
set "LLAMA_VISION_URL=%VISION_URL%"
set "DEFAULT_MODEL=%PRIMARY_NAME%"
set "ALLOWED_MODELS=qwen3-vl-2b-instruct,qwen2.5-1.5b-instruct,qwen3:4b"
set "MAX_REQUEST_BYTES=4194304"
REM Generous limits for a local CPU model — the machine itself is the real bottleneck.
set "REQUESTS_PER_MINUTE=60"
set "REQUESTS_PER_DAY=1000"
set "GLOBAL_REQUESTS_PER_DAY=1000"
set "WORKSPACE_ORIGINS=qoder.website,localhost"

curl -s -m 3 http://127.0.0.1:8000/health | find "\"ok\":true" >nul
if errorlevel 1 (
  echo Starting the response gateway on http://127.0.0.1:8000 ...
  start "Arch Hub gateway" /min py -m uvicorn app:app --host 127.0.0.1 --port 8000
  timeout /t 8 /nobreak >nul
) else (
  echo Gateway already running. Close its window first if you changed the model settings.
)

echo.
echo Check:
curl -s -m 8 http://127.0.0.1:8000/health
echo.
echo In Arch Hub open AI assistant, paste your gateway API key, press Save then Test connection.
pause
