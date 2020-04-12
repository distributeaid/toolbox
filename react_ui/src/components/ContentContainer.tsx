import React from 'react'

export const ContentContainer: React.FC = ({ children }) => (
  <div className="container w-full max-w-3xl p-4 md:mx-auto bg-white overflow-hidden">
    {children}
  </div>
)
