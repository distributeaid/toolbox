import React from 'react'

export const MainHeader: React.FC = ({ children }) => (
  <h1 className="font-heading font-semibold text-3xl sm:text-6xl leading-tight mb-8">
    {children}
  </h1>
)
