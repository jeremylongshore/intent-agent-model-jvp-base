"""
Unit tests for Supreme Commander Agent.

These tests mock external dependencies and test the agent logic.
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from app.agent import supreme_commander, handle_message


class TestSupremeCommanderAgent:
    """Test cases for Supreme Commander agent."""

    def test_agent_creation(self):
        """Test that agent is created successfully."""
        assert supreme_commander is not None
        assert supreme_commander.name == "supreme_commander"
        assert supreme_commander.model is not None

    def test_agent_has_tools(self):
        """Test that agent has all required tools."""
        tool_names = [tool.__name__ for tool in supreme_commander.tools]

        expected_tools = [
            "retrieve_knowledge",
            "create_task_plan",
            "track_goal_progress",
            "delegate_to_agent",
            "coordinate_with_peer_agent",
            "send_slack_notification",
            "update_firebase_dashboard",
        ]

        for tool in expected_tools:
            assert tool in tool_names, f"Missing tool: {tool}"

    @patch("app.agent.supreme_commander.send_message")
    def test_handle_message_basic(self, mock_send_message):
        """Test handling a basic message."""
        mock_send_message.return_value = "Test response"

        response = handle_message("Test message")

        assert response == "Test response"
        mock_send_message.assert_called_once()

    @patch("app.agent.supreme_commander.send_message")
    def test_handle_message_with_context(self, mock_send_message):
        """Test handling message with user context."""
        mock_send_message.return_value = "Test response"

        response = handle_message(
            message="Test message",
            user_id="user123",
            channel="general",
        )

        assert response == "Test response"

        # Check that context was added to message
        call_args = mock_send_message.call_args[0][0]
        assert "user123" in call_args
        assert "general" in call_args
        assert "Test message" in call_args


class TestAgentInstruction:
    """Test the agent's instruction/system prompt."""

    def test_instruction_includes_goal_alignment(self):
        """Test that instruction mentions goal alignment."""
        assert "goal" in supreme_commander.instruction.lower()
        assert "align" in supreme_commander.instruction.lower()

    def test_instruction_includes_task_organization(self):
        """Test that instruction mentions task organization."""
        assert "task" in supreme_commander.instruction.lower()
        assert "organiz" in supreme_commander.instruction.lower()

    def test_instruction_includes_delegation(self):
        """Test that instruction mentions delegation."""
        assert "delegate" in supreme_commander.instruction.lower()

    def test_instruction_includes_communication(self):
        """Test that instruction mentions communication."""
        assert "slack" in supreme_commander.instruction.lower()
        assert "firebase" in supreme_commander.instruction.lower()
