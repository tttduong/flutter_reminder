# flutter_reminder

download and extract zip 

***************cd server *****************

python -m venv venv              # Tạo môi trường ảo mới

# source venv/bin/activate         # (Trên macOS/Linux)
venv\Scripts\activate            # Trên Windows

pip install -r requirements.txt  # Cài đặt toàn bộ thư viện

# copy file doten

uvicorn main:app --reload        # run backend
(or):  uvicorn main:app --reload --log-level debug

run client (frontend):  main.dart -> click run

# (backend) thoát chế độ venv:  deactivate
# save tools in venv to requirement.txt: pip freeze > requirements.txt

venv\Scripts\activate  
uvicorn main:app --host 0.0.0.0 --port 8000
uvicorn main:app --reload --log-level debug


uvicorn main:app --reload 
venv\Scripts\activate  
python main.py
flutter run

https://claude.ai/chat/a6977722-41e0-4352-a8b6-8685cc2b883f


In case port 8000 is occupied:
netstat -ano | findstr :8000
taskkill /PID <PID> /F                 (ex: taskkill /PID 11840 /F )

