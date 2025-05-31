import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import VideoList from "./pages/VideoList";
import VideoPage from "./pages/VideoPage";
// v1
function App() {
    return (
              
        <Router>
            <Routes>
                <Route path="/" element={<VideoList />} />
                <Route path="/videos/:id" element={<VideoPage />} />
            </Routes>
        </Router>
    );
}

export default App;
