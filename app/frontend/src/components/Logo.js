import React from "react";
import { Link } from "react-router-dom";
import logoImage from "../assets/images/kisshub-logo.png"; // Đường dẫn đến file logo PNG

const Logo = () => {
  return (
    <div className="logo-container">
      <Link to="/">
        <img 
          src={logoImage} 
          alt="KissHub Logo" 
          className="logo-image"
        />
      </Link>
    </div>
  );
};

export default Logo;