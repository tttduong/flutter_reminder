# flutter_reminder

download and extract zip 

***************cd server *****************
##### RUN BACKEND ###########
cd server
python -m venv venv
venv\Scripts\activate  
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000


##### RUN FRONTEND ###########
cd client
flutter run


In case port 8000 is occupied:
netstat -ano | findstr :8000
taskkill /PID <PID> /F                 (ex: taskkill /PID 11840 /F )











# (backend) thoát chế độ venv:  deactivate
# save tools in venv to requirement.txt: pip freeze > requirements.txt


