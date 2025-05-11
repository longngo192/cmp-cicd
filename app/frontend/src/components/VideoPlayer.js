// src/components/VideoPlayer.js
import React, { useRef, useEffect } from "react";


const VideoPlayer = ({ src }) => {
  const videoRef = useRef(null);

  useEffect(() => {
    const videoElement = videoRef.current;
    
    // Thêm các sự kiện xử lý video nếu cần
    const handleVideoEnd = () => {
      console.log("Video đã kết thúc");
    };
    
    videoElement.addEventListener("ended", handleVideoEnd);
    
    return () => {
      videoElement.removeEventListener("ended", handleVideoEnd);
    };
  }, []);

  return (
    <div className="video-player-container">
      <video 
        ref={videoRef}
        controls
        className="video-player"
        autoPlay
      >
        <source src={src} type="video/mp4" />
        Trình duyệt của bạn không hỗ trợ thẻ video.
      </video>
    </div>
  );
};

export default VideoPlayer;