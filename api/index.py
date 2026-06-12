# Vercel Serverless Function - KaiHub Key Verification API
# 访问方式: /api/check?key=KAIHUB-TEST-001
#           /api/use?key=KAIHUB-TEST-001&device=device123

import json
import os
from http.server import BaseHTTPRequestHandler
from datetime import datetime

# 内存存储（Vercel 无状态，每次部署重置）
# 生产环境应使用数据库
USED_KEYS = {}
VALID_KEYS = [
    "KAIHUB-TEST-001",
    "KAIHUB-TEST-002", 
    "KAIHUB-TEST-003",
    "KAIHUB-VIP-001",
    "KAIHUB-VIP-002"
]

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = self.path
        
        # 设置 CORS 头
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.end_headers()
        
        # 解析查询参数
        params = {}
        if '?' in path:
            query = path.split('?')[1]
            for param in query.split('&'):
                if '=' in param:
                    k, v = param.split('=', 1)
                    params[k] = v
        
        action = path.split('?')[0].split('/')[-1]
        
        if action == 'check':
            # 检查卡密状态
            key = params.get('key', '')
            if key in USED_KEYS:
                response = {
                    "valid": False,
                    "used": True,
                    "device": USED_KEYS[key].get('device', ''),
                    "message": "Key already used"
                }
            elif key in VALID_KEYS:
                response = {
                    "valid": True,
                    "used": False,
                    "message": "Key is valid"
                }
            else:
                response = {
                    "valid": False,
                    "used": False,
                    "message": "Invalid key"
                }
        
        elif action == 'use':
            # 使用卡密
            key = params.get('key', '')
            device = params.get('device', 'unknown')
            
            if key in USED_KEYS:
                response = {
                    "success": False,
                    "message": "Key already used by another device",
                    "device": USED_KEYS[key].get('device', '')
                }
            elif key in VALID_KEYS:
                USED_KEYS[key] = {
                    "device": device,
                    "time": datetime.now().isoformat(),
                    "used": True
                }
                response = {
                    "success": True,
                    "message": "Key activated successfully"
                }
            else:
                response = {
                    "success": False,
                    "message": "Invalid key"
                }
        
        elif action == 'list':
            # 查看已用卡密（管理员用）
            response = {
                "used_keys": USED_KEYS,
                "valid_keys": VALID_KEYS
            }
        
        else:
            response = {
                "message": "KaiHub Key Verification API",
                "endpoints": [
                    "/api/check?key=YOUR_KEY",
                    "/api/use?key=YOUR_KEY&device=DEVICE_ID",
                    "/api/list"
                ]
            }
        
        self.wfile.write(json.dumps(response).encode())
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
