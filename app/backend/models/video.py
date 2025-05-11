from app import db

class Video(db.Model):
    __tablename__ = "videos"

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=True)
    video_url = db.Column(db.String(255), nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
        "video_url": self.video_url
    }
