import React from 'react'

type Props = {
  href: string
}

export const TextLink: React.FC<Props> = ({ children, href }) => (
  <a className="underline text-blue-600 visited:text-purple-600" href={href}>{children}</a>
);
