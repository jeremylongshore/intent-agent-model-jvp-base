"""
Unit tests for Supreme Commander tools.

These tests mock external services (Firebase, Slack, etc.)
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from app.tools import (
    delegate_to_agent,
    coordinate_with_peer_agent,
    send_slack_notification,
    update_firebase_dashboard,
    create_task_plan,
    track_goal_progress,
)


@pytest.fixture
def mock_firestore():
    """Mock Firestore client."""
    with patch("app.tools.firestore.client") as mock_client:
        yield mock_client


@pytest.fixture
def mock_slack():
    """Mock Slack client."""
    with patch("app.tools.slack_client") as mock_client:
        yield mock_client


@pytest.fixture
def mock_firebase_db():
    """Mock Firebase Realtime Database."""
    with patch("app.tools.db.reference") as mock_ref:
        yield mock_ref


class TestDelegationTools:
    """Test task delegation and coordination tools."""

    def test_delegate_to_agent(self, mock_firestore):
        """Test delegating a task to an agent."""
        mock_doc_ref = Mock()
        mock_doc_ref.id = "task_123"
        mock_firestore.return_value.collection.return_value.document.return_value = mock_doc_ref

        result = delegate_to_agent(
            agent_id="test_agent",
            task_description="Test task",
            priority="high",
        )

        assert "success" in result.lower()
        assert "task_123" in result
        mock_doc_ref.set.assert_called_once()

    def test_delegate_to_agent_handles_errors(self, mock_firestore):
        """Test error handling in delegation."""
        mock_firestore.return_value.collection.side_effect = Exception("Database error")

        result = delegate_to_agent(
            agent_id="test_agent",
            task_description="Test task",
        )

        assert "failed" in result.lower() or "error" in result.lower()

    def test_coordinate_with_peer_agent(self, mock_firestore):
        """Test coordinating with peer agent."""
        mock_doc_ref = Mock()
        mock_doc_ref.id = "coord_456"
        mock_firestore.return_value.collection.return_value.document.return_value = mock_doc_ref

        result = coordinate_with_peer_agent(
            peer_agent_id="peer_agent",
            request="Need information",
        )

        assert "coord_456" in result
        mock_doc_ref.set.assert_called_once()


class TestCommunicationTools:
    """Test Slack and Firebase communication tools."""

    def test_send_slack_notification_success(self, mock_slack):
        """Test successful Slack notification."""
        mock_slack.chat_postMessage.return_value = {"ok": True, "ts": "1234.5678"}

        result = send_slack_notification(
            channel="general",
            message="Test message",
            priority="info",
        )

        assert "success" in result.lower()
        mock_slack.chat_postMessage.assert_called_once()

    def test_send_slack_notification_critical_priority(self, mock_slack):
        """Test critical priority adds @channel mention."""
        mock_slack.chat_postMessage.return_value = {"ok": True, "ts": "1234.5678"}

        send_slack_notification(
            channel="general",
            message="Critical alert",
            priority="critical",
        )

        call_args = mock_slack.chat_postMessage.call_args
        message_text = call_args.kwargs.get("text", "")

        assert "<!channel>" in message_text
        assert "🚨" in message_text

    def test_update_firebase_dashboard(self, mock_firebase_db):
        """Test updating Firebase dashboard."""
        mock_ref = Mock()
        mock_firebase_db.return_value = mock_ref

        result = update_firebase_dashboard(
            metric_type="task_status",
            data={"active": 5, "completed": 10},
        )

        assert "success" in result.lower()
        mock_ref.set.assert_called_once()


class TestTaskManagementTools:
    """Test task planning and tracking tools."""

    def test_create_task_plan(self, mock_firestore):
        """Test creating a task plan."""
        mock_doc_ref = Mock()
        mock_doc_ref.id = "plan_789"
        mock_firestore.return_value.collection.return_value.document.return_value = mock_doc_ref

        result = create_task_plan(
            objective="Deploy new feature",
            context="Production environment",
        )

        assert "plan_789" in result
        mock_doc_ref.set.assert_called_once()

    def test_track_goal_progress_task_exists(self, mock_firestore):
        """Test tracking progress for existing task."""
        mock_task_doc = Mock()
        mock_task_doc.exists = True
        mock_task_doc.to_dict.return_value = {
            "agent_id": "test_agent",
            "task_description": "Test task",
            "status": "in_progress",
            "priority": "high",
        }

        mock_firestore.return_value.collection.return_value.document.return_value.get.return_value = mock_task_doc

        result = track_goal_progress("task_123")

        assert "in_progress" in result.lower()
        assert "test_agent" in result.lower()

    def test_track_goal_progress_not_found(self, mock_firestore):
        """Test tracking non-existent goal."""
        mock_task_doc = Mock()
        mock_task_doc.exists = False

        mock_plan_doc = Mock()
        mock_plan_doc.exists = False

        mock_firestore.return_value.collection.return_value.document.return_value.get.side_effect = [
            mock_task_doc,
            mock_plan_doc,
        ]

        result = track_goal_progress("nonexistent_123")

        assert "not found" in result.lower()
