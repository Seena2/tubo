from app.app import app


def test_app_boots():
    assert app is not None


def test_index_route():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code in (200, 404)
