import React from "react"

export const ContentContainer: React.FC = ({ children }) => (
  <div className="w-full max-w-3xl mx-auto bg-white overflow-hidden md:shadow md:rounded-lg md:border-t md:border-gray-100">
    {children}
  </div>
)
