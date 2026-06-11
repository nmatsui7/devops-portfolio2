def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "healthy"

def test_ready(client):
    resp = client.get("/ready")
    assert resp.status_code == 200

def test_metrics(client):
    resp = client.get("/metrics")
    assert resp.status_code == 200

def test_list_todos_empty(client):
    resp = client.get("/api/todos")
    assert resp.status_code == 200
    assert resp.get_json() == []

def test_create_todo(client):
    resp = client.post("/api/todos", json={"title": "test todo"})
    assert resp.status_code == 201
    data = resp.get_json()
    assert data["title"] == "test todo"
    assert data["completed"] is False

def test_create_todo_no_title(client):
    resp = client.post("/api/todos", json={})
    assert resp.status_code == 400

def test_get_todo(client):
    create = client.post("/api/todos", json={"title": "get me"})
    todo_id = create.get_json()["id"]
    resp = client.get(f"/api/todos/{todo_id}")
    assert resp.status_code == 200
    assert resp.get_json()["title"] == "get me"

def test_get_todo_not_found(client):
    resp = client.get("/api/todos/999")
    assert resp.status_code == 404

def test_update_todo(client):
    create = client.post("/api/todos", json={"title": "update me"})
    todo_id = create.get_json()["id"]
    resp = client.put(f"/api/todos/{todo_id}", json={"completed": True})
    assert resp.status_code == 200
    assert resp.get_json()["completed"] is True

def test_delete_todo(client):
    create = client.post("/api/todos", json={"title": "delete me"})
    todo_id = create.get_json()["id"]
    resp = client.delete(f"/api/todos/{todo_id}")
    assert resp.status_code == 200
    resp2 = client.get(f"/api/todos/{todo_id}")
    assert resp2.status_code == 404
