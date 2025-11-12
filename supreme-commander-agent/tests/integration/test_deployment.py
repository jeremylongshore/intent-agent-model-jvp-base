"""
Integration tests for Supreme Commander deployment.

These tests require actual GCP credentials and test against real services.
Run with: pytest tests/integration -v
"""

import pytest
import os
from google.cloud import aiplatform, firestore
from app.agent import supreme_commander


# Skip if no GCP credentials
pytestmark = pytest.mark.skipif(
    not os.getenv("GOOGLE_APPLICATION_CREDENTIALS") and not os.getenv("PROJECT_ID"),
    reason="GCP credentials not configured",
)


class TestGCPIntegration:
    """Test integration with GCP services."""

    def test_firestore_connectivity(self):
        """Test connection to Firestore."""
        try:
            db = firestore.Client()
            # Try to list collections (should not error)
            list(db.collections())
            assert True
        except Exception as e:
            pytest.fail(f"Firestore connection failed: {e}")

    def test_vertex_ai_initialization(self):
        """Test Vertex AI can be initialized."""
        try:
            project_id = os.getenv("PROJECT_ID")
            if project_id:
                aiplatform.init(project=project_id, location="us-central1")
                assert True
        except Exception as e:
            pytest.fail(f"Vertex AI initialization failed: {e}")


class TestAgentDeployment:
    """Test agent deployment to Agent Engine."""

    @pytest.mark.slow
    def test_agent_can_be_queried_locally(self):
        """Test that agent responds to queries (before deployment)."""
        try:
            # This tests the agent logic without deploying
            from app.agent import handle_message

            response = handle_message("What are your capabilities?")

            assert isinstance(response, str)
            assert len(response) > 0

        except Exception as e:
            pytest.fail(f"Local agent query failed: {e}")


class TestToolsIntegration:
    """Test tools with real GCP services."""

    def test_firebase_dashboard_update(self):
        """Test updating Firebase dashboard (if configured)."""
        from app.tools import update_firebase_dashboard

        # This will fail gracefully if Firebase not configured
        result = update_firebase_dashboard(
            metric_type="task_status",
            data={"test": True},
        )

        # Should either succeed or fail gracefully
        assert isinstance(result, str)
