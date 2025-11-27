# Locust Load Test Script for T-CLO-901
# GitHub: https://github.com/locustio/locust
# Installation: pip install locust

from locust import HttpUser, task, between
import random
import json

class T_CLO_901_User(HttpUser):
    wait_time = between(1, 3)  # Wait 1-3 seconds between tasks
    
    def on_start(self):
        """Called when a user starts"""
        print(f"🚀 User {self.environment.runner.user_count} started")
        
        # Optional: Login or setup tasks
        # self.login()
    
    def on_stop(self):
        """Called when a user stops"""
        print(f"✅ User stopped")
    
    @task(7)  # Weight: 70% of requests
    def homepage(self):
        """Test homepage"""
        with self.client.get("/", catch_response=True) as response:
            if response.status_code == 200:
                if "EPITECH T-CLO-901" in response.text:
                    response.success()
                else:
                    response.failure("Homepage doesn't contain expected content")
            else:
                response.failure(f"Got status code {response.status_code}")
    
    @task(3)  # Weight: 30% of requests
    def counter_api(self):
        """Test counter API"""
        with self.client.get("/api/counter/add", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    json_response = response.json()
                    if "value" in json_response:
                        response.success()
                    else:
                        response.failure("API response missing 'value' field")
                except json.JSONDecodeError:
                    response.failure("Response is not valid JSON")
            else:
                response.failure(f"Got status code {response.status_code}")
    
    @task(1)  # Weight: 10% of requests
    def user_journey(self):
        """Simulate a complete user journey"""
        # Visit homepage
        self.client.get("/")
        
        # Wait a bit (user reading)
        self.wait()
        
        # Click counter multiple times
        for _ in range(random.randint(2, 5)):
            self.client.get("/api/counter/add")
            self.wait_time = between(0.5, 1.5)  # Faster clicks
    
    def login(self):
        """Optional login function"""
        # If your app has authentication
        # response = self.client.post("/login", {
        #     "username": "test@example.com",
        #     "password": "password123"
        # })
        pass

# Custom user class for API-only testing
class APIOnlyUser(HttpUser):
    wait_time = between(0.5, 2)
    weight = 1  # Lower weight compared to normal users
    
    @task
    def api_only(self):
        """Only test API endpoints"""
        self.client.get("/api/counter/add")

# Configuration for different test scenarios
class QuickTestUser(T_CLO_901_User):
    """Quick test configuration"""
    wait_time = between(0.5, 1)
    weight = 3

class HeavyUser(T_CLO_901_User):
    """Heavy user simulation"""
    wait_time = between(0.1, 0.5)
    weight = 1
    
    @task(10)
    def heavy_api_usage(self):
        """Simulate heavy API usage"""
        for _ in range(10):
            self.client.get("/api/counter/add")

"""
Usage:

1. Install Locust:
   pip install locust

2. Basic test:
   locust -f locust-test.py --host=https://app-dev-stg10.azurewebsites.net

3. Headless mode (no web UI):
   locust -f locust-test.py --host=https://app-dev-stg10.azurewebsites.net --users 50 --spawn-rate 5 --run-time 5m --headless

4. With specific user class:
   locust -f locust-test.py --host=https://app-dev-stg10.azurewebsites.net QuickTestUser

5. Generate HTML report:
   locust -f locust-test.py --host=https://app-dev-stg10.azurewebsites.net --users 25 --spawn-rate 2 --run-time 2m --headless --html report.html

6. CSV output:
   locust -f locust-test.py --host=https://app-dev-stg10.azurewebsites.net --users 25 --spawn-rate 2 --run-time 2m --headless --csv results

Test scenarios:
- Light load: --users 10 --spawn-rate 1 --run-time 2m
- Medium load: --users 50 --spawn-rate 5 --run-time 5m  
- Heavy load: --users 100 --spawn-rate 10 --run-time 10m
- Spike test: --users 200 --spawn-rate 50 --run-time 2m
"""
