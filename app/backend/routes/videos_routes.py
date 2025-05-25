from flask import Blueprint, jsonify, request
from app import db
from models.video import Video

videos_routes = Blueprint("videos_routes", __name__)

# Get all videos
@videos_routes.route("/api/videos", methods=["GET"])
def get_videos():
    videos = Video.query.all()
    return jsonify([video.to_dict() for video in videos]), 200

# Get task by ID
@videos_routes.route("/api/videos/<int:video_id>", methods=["GET"])
def get_video(video_id):
    video = Video.query.get(video_id)
    if not video:
        return jsonify({"error": "Video not found"}), 404
    return jsonify(video.to_dict()), 200

# Create a new task
@videos_routes.route("/api/videos", methods=["POST"])
def create_video():
    data = request.get_json()
    new_video = Video(title=data["title"], description=data.get("description"), video_url=data["video_url"])
    db.session.add(new_video)
    db.session.commit()
    return jsonify(new_video.to_dict()), 201

# Update a task
@videos_routes.route("/api/videos/<int:video_id>", methods=["PUT"])
def update_video(video_id):
    video = Video.query.get(video_id)
    if not video:
        return jsonify({"error": "Video not found"}), 404

    data = request.get_json()
    video.title = data.get("title", video.title)
    video.description = data.get("description", video.description)
    video.video_url = data.get("video_url", video.video_url)

    db.session.commit()
    return jsonify(video.to_dict()), 200

# Delete a task
@videos_routes.route("/api/videos/<int:video_id>", methods=["DELETE"])
def delete_video(video_id):
    video = Video.query.get(video_id)
    if not video:
        return jsonify({"error": "Video not found"}), 404

    db.session.delete(video)
    db.session.commit()
    return jsonify({"message": "Video deleted"}), 200
