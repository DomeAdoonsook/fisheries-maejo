@echo off
echo Starting server...
start "" "http://localhost:8000"
"C:\Users\Lenovo\AppData\Local\Python\bin\python.exe" -m http.server 8000
