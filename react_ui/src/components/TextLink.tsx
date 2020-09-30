import React from 'react'

type Props = {
  href: string
  newTab?: boolean
}

export const TextLink: React.FC<Props> = ({ children, href, newTab }) => (
  <a
    className="underline text-blue-600 visited:text-purple-600"
    target={newTab ? '_blank' : ''}
    href={href}>
    {children}
  </a>
)
