# flutter_reminder

download and extract zip 

***************cd server *****************

python -m venv venv              # Tạo môi trường ảo mới

source venv/bin/activate         # (Trên macOS/Linux)
venv\Scripts\activate            # Trên Windows

pip install -r requirements.txt  # Cài đặt toàn bộ thư viện

# copy file doten

uvicorn main:app --reload        # run backend

run client (frontend):  main.dart -> click run

# (backend) thoát chế độ venv:  deactivate