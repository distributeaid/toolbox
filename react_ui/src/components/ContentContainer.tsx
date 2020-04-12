import React from 'react'

export const ContentContainer: React.FC = ({ children }) => (
  <div className="container w-full max-w-5xl p-4 md:mx-auto bg-white overflow-hidden">
    {children}
  </div>
)
