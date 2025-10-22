# import logging
# # from fastapi import Request
# from starlette.requests import Request
# from starlette.responses import Response
# from fastapi import Request, HTTPException
# from starlette.middleware.base import BaseHTTPMiddleware

# logger = logging.getLogger(__name__)
# logger.setLevel(logging.INFO)
# handler = logging.FileHandler('info.log')
# handler.setLevel(logging.INFO)
# formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
# handler.setFormatter(formatter)
# logger.addHandler(handler)


# # async def logging_middleware(request: Request, call_next):
# #     logger.info(f"Incoming request: {request.method} {request.url.path}")
# #     response = await call_next(request)
# #     logger.info(f"Outgoing response code: {response.status_code}")
# #     return response

# async def logging_middleware(request: Request, call_next):
#     # đọc body gốc
#     body = await request.body()
#     print("📥 Request body:", body.decode("utf-8"))

#     # tạo receive async function để trả lại body cho downstream
#     async def receive():
#         return {"type": "http.request", "body": body, "more_body": False}

#     # gắn lại request với body
#     request = Request(request.scope, receive)

#     # gọi tiếp xuống route
#     response: Response = await call_next(request)

#     # đọc response body
#     resp_body = b""
#     async for chunk in response.body_iterator:
#         resp_body += chunk

#     print("📤 Response body:", resp_body.decode("utf-8"))

#     # trả response mới (để client vẫn nhận được body)
#     return Response(
#         content=resp_body,
#         status_code=response.status_code,
#         headers=dict(response.headers),
#         media_type=response.media_type
#     )



# class AuthMiddleware(BaseHTTPMiddleware):
#     async def dispatch(self, request: Request, call_next):
#         # ⭐ DEBUG
#         print(f"📨 Request path: {request.url.path}")
#         print(f"🍪 Request cookies: {request.cookies}")
#         print(f"📦 Session data: {dict(request.session) if hasattr(request, 'session') else 'No session'}")
        
#         # Skip auth cho public routes
#         public_routes = ["/api/v1/login", "/api/v1/register", "/docs", "/openapi.json"]
#         if request.url.path in public_routes:
#             response = await call_next(request)
#             return response
        
#         # Check authentication
#         user_id = request.session.get("user_id")
#         if not user_id:
#             print("❌ No user_id in session - Unauthorized")
#             return JSONResponse(
#                 status_code=401,
#                 content={"detail": "Unauthorized"}
#             )
        
#         print(f"✅ Authenticated user_id: {user_id}")
#         response = await call_next(request)
#         return response
import logging
from starlette.requests import Request
from starlette.responses import Response
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.FileHandler('info.log')
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)


async def logging_middleware(request: Request, call_next):
    """Middleware để log request/response body"""
    try:
        # Đọc body gốc
        body = await request.body()
        print(f"📥 Request: {request.method} {request.url.path}")
        if body:
            print(f"📥 Body: {body.decode('utf-8')[:500]}")

        # Tạo receive function để trả lại body
        async def receive():
            return {"type": "http.request", "body": body, "more_body": False}

        # Gắn lại request với body
        request = Request(request.scope, receive)

        # Gọi tiếp xuống route
        response: Response = await call_next(request)

        # Đọc response body
        resp_body = b""
        async for chunk in response.body_iterator:
            resp_body += chunk

        print(f"📤 Response: {response.status_code}")
        if resp_body:
            print(f"📤 Body: {resp_body.decode('utf-8')[:500]}")

        # Trả response mới
        return Response(
            content=resp_body,
            status_code=response.status_code,
            headers=dict(response.headers),
            media_type=response.media_type
        )
    except Exception as e:
        print(f"❌ Logging middleware error: {e}")
        return await call_next(request)


class AuthMiddleware(BaseHTTPMiddleware):
    # async def dispatch(self, request: Request, call_next):
    #     try:
    #         print(f"📨 Request: {request.method} {request.url.path}")
    #         print(f"🍪 Cookies: {request.cookies}")
    #         # print(f"🔍 Session data: {dict(request.session)}")  # ✅ THÊM DÒNG NÀY
    #         # print(f"🔍 Session keys: {list(request.session.keys())}")  # ✅ THÊM DÒNG NÀY
            
    #         # ⭐ CÁCH ĐÚNG để check session
    #         session_data = None
    #         try:
    #             # Chỉ truy cập session nếu "session" có trong scope
    #             if "session" in request.scope:
    #                 session_data = dict(request.session)
    #                 print(f"📦 Session: {session_data}")
    #             else:
    #                 print("⚠️ No session in scope")
    #         except (AssertionError, RuntimeError) as e:
    #             print(f"⚠️ Cannot access session: {e}")
            
    #         # Skip auth cho public routes
    #         public_routes = [
    #             "/api/v1/login", 
    #             "/api/v1/register", 
    #             "/docs", 
    #             "/openapi.json",
    #             "/",
    #             "/health",
    #         ]
            
    #         if request.url.path in public_routes:
    #             print(f"✅ Public route, skipping auth")
    #             response = await call_next(request)
    #             return response
            
    #         # Check authentication
    #         user_id = None
    #         try:
    #             if "session" in request.scope:
    #                 user_id = request.session.get("user_id")
    #         except (AssertionError, RuntimeError):
    #             pass
            
    #         if not user_id:
    #             print("❌ No user_id in session - Unauthorized")
    #             return JSONResponse(
    #                 status_code=401,
    #                 content={"detail": "Unauthorized - Please login"}
    #             )
            
    #         print(f"✅ Authenticated user_id: {user_id}")
    #         response = await call_next(request)
    #         return response
            
    #     except Exception as e:
    #         print(f"❌ AuthMiddleware error: {e}")
    #         import traceback
    #         traceback.print_exc()
    #         return JSONResponse(
    #             status_code=500,
    #             content={"detail": "Authentication error", "error": str(e)}
    #         )
    # async def dispatch(self, request: Request, call_next):
    #     print(f"📨 Request: {request.method} {request.url.path}")
    #     print(f"🍪 Cookies: {request.cookies}")

    #     # ✅ Bước 1: Bỏ qua các route public NGAY ĐẦU
    #     public_routes = [
    #         "/api/v1/login",
    #         "/api/v1/register",
    #         "/docs",
    #         "/openapi.json",
    #         "/",
    #         "/health",
    #     ]
    
    #     if request.url.path in public_routes:
    #         print("✅ Public route, skipping auth")
    #         return await call_next(request)

    #     # ✅ Bước 2: Kiểm tra session scope
    #     if "session" not in request.scope:
    #         print("⚠️ No session in scope")
    #         return JSONResponse(
    #             status_code=401,
    #             content={"detail": "No session found - Unauthorized"},
    #         )

    #     # ✅ Bước 3: Lấy dữ liệu session an toàn
    #     try:
    #         session_data = dict(request.session)
    #         print(f"📦 Session data: {session_data}")
    #         user_id = request.session.get("user_id")
    #     except Exception as e:
    #         print(f"⚠️ Cannot access session: {e}")
    #         user_id = None

    #     # ✅ Bước 4: Kiểm tra user_id
    #     if not user_id:
    #         print("❌ No user_id in session - Unauthorized")
    #         return JSONResponse(
    #             status_code=401,
    #             content={"detail": "Unauthorized - Please login"},
    #         )

    #     print(f"✅ Authenticated user_id: {user_id}")
    #     return await call_next(request)
    async def dispatch(self, request: Request, call_next):
        print(f"📨 Request: {request.method} {request.url.path}")
        print(f"🍪 Cookies (client → server): {request.cookies}")

        # ✅ Bước 1: Public routes (bỏ qua auth)
        public_routes = [
            "/api/v1/login",
            "/api/v1/register",
            "/docs",
            "/openapi.json",
            "/",
            "/health",
        ]
        if request.url.path in public_routes:
            print("✅ Public route, skipping auth")
            response = await call_next(request)
        else:
            # ✅ Bước 2: Kiểm tra session
            if "session" not in request.scope:
                print("⚠️ No session in scope")
                return JSONResponse(
                    status_code=401,
                    content={"detail": "No session found - Unauthorized"},
                )

            try:
                session_data = dict(request.session)
                print(f"📦 Session data (decoded): {session_data}")
                user_id = request.session.get("user_id")
            except Exception as e:
                print(f"⚠️ Cannot access session: {e}")
                user_id = None

            if not user_id:
                print("❌ No user_id in session - Unauthorized")
                return JSONResponse(
                    status_code=401,
                    content={"detail": "Unauthorized - Please login"},
                )

            print(f"✅ Authenticated user_id: {user_id}")
            response = await call_next(request)

        # ✅ Bước 3: In Set-Cookie thực tế BE gửi cho client
        print("🍪 Final response headers:")
        for k, v in response.raw_headers:
            print(f"   {k.decode()}: {v.decode()}")

        set_cookie_headers = [
            v.decode()
            for k, v in response.raw_headers
            if k.lower() == b"set-cookie"
        ]
        if set_cookie_headers:
            print("✅ Set-Cookie headers sent to client:")
            for cookie in set_cookie_headers:
                print(f"   → {cookie}")
        else:
            print("⚠️ No Set-Cookie header in response")

        return response