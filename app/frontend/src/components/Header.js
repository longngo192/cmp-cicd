// src/components/Header.js
import React, { useState } from "react";
import Logo from "./Logo";  

const Header = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [activeCategory, setActiveCategory] = useState("all");

  const categories = [
    { id: "all", name: "Tất cả" },
    { id: "tutorials", name: "Hướng dẫn" },
    { id: "programming", name: "Lập trình" },
    { id: "react", name: "React" },
    { id: "javascript", name: "JavaScript" },
    { id: "css", name: "CSS" },
    { id: "nodejs", name: "Node.js" },
    { id: "web", name: "Web Development" }
  ];

  const handleSearch = (e) => {
    e.preventDefault();
    console.log("Searching for:", searchTerm);
    // Thực hiện tìm kiếm ở đây
  };

  return (
    <div className="header-container">
      <div className="site-header">
        <Logo />
        <form className="search-container" onSubmit={handleSearch}>
          <input
            type="text"
            className="search-input"
            placeholder="Tìm kiếm video..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <button type="submit" className="search-button">
            Tìm
          </button>
        </form>
      </div>
      
      <div className="category-nav">
        {categories.map((category) => (
          <button
            key={category.id}
            className={`category-button ${activeCategory === category.id ? 'active' : ''}`}
            onClick={() => setActiveCategory(category.id)}
          >
            {category.name}
          </button>
        ))}
      </div>
    </div>
  );
};

export default Header;