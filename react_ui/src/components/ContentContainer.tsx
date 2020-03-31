import React from "react";

export const ContentContainer: React.FC = ({ children }) => (
  <div className="w-full max-w-3xl mx-auto shadow rounded-lg overflow-hidden bg-white p-8 border-t border-gray-100">
    {children}
  </div>
);
