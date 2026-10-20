@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
title Lanzador de Steam - Sin Admin

:: ============================================================
:: STEAM SIN ADMIN - COPIA A RUTA ASCII
:: ============================================================

:: No concede permisos de administrador.
:: Intenta ejecutar aplicaciones con los permisos del usuario actual.
set "__COMPAT_LAYER=RunAsInvoker"

:: Carpeta real donde esta este BAT
set "ORIGEN=%~dp0"

:: Quitar "\" final
if "%ORIGEN:~-1%"=="\" set "ORIGEN=%ORIGEN:~0,-1%"

:: Ruta sin acentos ni caracteres especiales
set "DESTINO=C:\Users\Public\steam"


:: ============================================================
:: SI YA ESTAMOS EN DESTINO, NO VOLVER A COPIAR
:: ============================================================

if /I "%ORIGEN%"=="%DESTINO%" goto EJECUTAR_STEAM


echo.
echo ============================================================
echo       PREPARANDO STEAM EN RUTA SIN ACENTOS
echo ============================================================
echo.
echo Origen:
echo "%ORIGEN%"
echo.
echo Destino:
echo "%DESTINO%"
echo.


:: ============================================================
:: CREAR CARPETA DESTINO
:: ============================================================

if not exist "%DESTINO%" (
    mkdir "%DESTINO%" 2>nul

    if errorlevel 1 (
        echo.
        echo [FAIL] No se ha podido crear:
        echo "%DESTINO%"
        echo.
        echo Tu usuario no tiene permisos de escritura en esa carpeta.
        pause
        exit /b 1
    )
)


:: ============================================================
:: COPIAR STEAM
:: Robocopy funciona mejor que XCOPY con rutas Unicode/acentos.
:: ============================================================

echo [INFO] Copiando/actualizando archivos...
echo.

robocopy "%ORIGEN%" "%DESTINO%" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /XJ /NP /NFL /NDL /NJH /NJS

:: Robocopy usa codigos 0-7 como resultados correctos.
:: 8 o superior significa error real.

if errorlevel 8 (
    echo.
    echo [FAIL] Ha ocurrido un error copiando Steam.
    echo.
    echo Origen:
    echo "%ORIGEN%"
    echo.
    echo Destino:
    echo "%DESTINO%"
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Archivos preparados correctamente.


:: ============================================================
:: EJECUTAR STEAM DESDE LA RUTA ASCII
:: ============================================================

:EJECUTAR_STEAM

cd /d "%DESTINO%" 2>nul

if errorlevel 1 (
    echo.
    echo [FAIL] No se puede acceder a:
    echo "%DESTINO%"
    pause
    exit /b 1
)

echo.
echo ============================================================
echo              INICIANDO STEAM
echo ============================================================
echo.


:: Steam ya instalado / descomprimido
if exist "%DESTINO%\steam.exe" (
    echo [OK] Ejecutando:
    echo "%DESTINO%\steam.exe"
    echo.

    start "" /D "%DESTINO%" "%DESTINO%\steam.exe"

    exit /b 0
)


:: Si solamente tenemos el instalador
if exist "%DESTINO%\SteamSetup.exe" (
    echo [INFO] steam.exe no existe todavia.
    echo [OK] Ejecutando SteamSetup.exe desde ruta ASCII...
    echo.

    start "" /D "%DESTINO%" "%DESTINO%\SteamSetup.exe"

    exit /b 0
)


:: ============================================================
:: ERROR
:: ============================================================

echo [FAIL] No se encuentra Steam.
echo.
echo Se esperaba encontrar:
echo.
echo "%DESTINO%\steam.exe"
echo.
echo o:
echo.
echo "%DESTINO%\SteamSetup.exe"
echo.
echo Mete este BAT dentro de la carpeta donde tienes Steam
echo y vuelve a ejecutarlo.
echo.

pause
exit /b 1
