import React, { useCallback, useState } from 'react'
import { NavLink } from 'react-router-dom'

import { M4DLogo } from './M4DLogo'

const showStyleguide = process.env.NODE_ENV === 'development'

export const NavBar: React.FC = () => {
  const [menuOpen, setMenuOpen] = useState(false)

  const toggleMenu = useCallback(() => {
    setMenuOpen((open) => !open)
  }, [])

  const hideMenu = useCallback(() => {
    setMenuOpen(false)
  }, [])

  return (
    <header className="sticky top-0 z-50">
      <nav className="flex items-center justify-between flex-wrap flex-shrink-0 w-full max-w-7xl mx-auto rounded-b bg-gray-900 font-heading text-gray-100 py-3 px-4">
        <div className="flex items-center flex-shrink-0 mr-9">
          <NavLink to="/">
            <M4DLogo />
          </NavLink>
        </div>
        <div className="block lg:hidden">
          <button
            onClick={toggleMenu}
            data-cy="toggle-menu"
            className="flex items-center px-3 py-2 border rounded border-white focus:outline-none">
            <svg
              className="fill-current h-3 w-3"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg">
              <title>Toggle Menu</title>
              <path d="M0 3h20v2H0V3zm0 6h20v2H0V9zm0 6h20v2H0v-2z" />
            </svg>
          </button>
        </div>
        <div
          className={`w-full ${
            menuOpen ? 'block' : 'hidden'
          } flex-grow lg:flex lg:items-center lg:w-auto`}>
          <div className="text-sm lg:flex-grow">
            <HeaderNavLink onClick={hideMenu} to="/about" label="About Us" />
            <HeaderNavLink onClick={hideMenu} to="/news" label="News" />
            <HeaderNavLink
              onClick={hideMenu}
              to="/involved"
              label="Get Involved"
            />
            <HeaderNavLink
              onClick={hideMenu}
              to="/supplies"
              label="Get Supplies"
            />
            <HeaderNavLink
              onClick={hideMenu}
              to="/chapters"
              label="Local Chapters"
            />
            <HeaderNavLink
              onClick={hideMenu}
              to="/resources"
              label="Resources"
            />
            <HeaderNavLink onClick={hideMenu} to="/faq" label="FAQ" />
            {showStyleguide && (
              <HeaderNavLink
                onClick={hideMenu}
                to="/style-guide"
                label="Style guide"
              />
            )}
          </div>
          <div>
            <NavLink
              to="/donate"
              onClick={hideMenu}
              className="bg-pink-500 inline-block text-sm px-4 py-2 leading-none rounded hover:border-transparent hover:text-teal-500 hover:bg-white mt-4 lg:mt-0">
              Donate
            </NavLink>
          </div>
        </div>
      </nav>
    </header>
  )
}

const navLinkClassName =
  'block mt-4 lg:inline-block lg:mt-0 hover:text-pink-300 active:text-pink-400 cursor-pointer mr-9'

const HeaderNavLink: React.FC<{
  onClick?: () => void
  to: string
  label: string
}> = ({ to, label, onClick, ...rest }) => (
  <NavLink onClick={onClick} to={to} className={navLinkClassName} {...rest}>
    {label}
  </NavLink>
)
