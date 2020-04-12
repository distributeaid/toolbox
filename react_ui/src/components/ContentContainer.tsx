import React from 'react'

export const ContentContainer: React.FC = ({ children }) => (
  <div className="w-full max-w-3xl mx-auto bg-white overflow-hidden py-4">
    {children}
  </div>
)
