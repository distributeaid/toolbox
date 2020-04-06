import React, { useState, useCallback } from 'react'

import { NavLink } from 'react-router-dom'

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
      <nav className="flex items-center justify-between flex-wrap bg-gray-900 text-gray-100 py-2 px-3">
        <div className="flex items-center flex-shrink-0 mr-9">
          <NavLink to="/">
            {/* todo replace with mask for docs logo */}
            <svg
              className="fill-current h-8 w-8 mr-2"
              width="54"
              height="54"
              viewBox="0 0 54 54"
              xmlns="http://www.w3.org/2000/svg">
              <path d="M13.5 22.1c1.8-7.2 6.3-10.8 13.5-10.8 10.8 0 12.15 8.1 17.55 9.45 3.6.9 6.75-.45 9.45-4.05-1.8 7.2-6.3 10.8-13.5 10.8-10.8 0-12.15-8.1-17.55-9.45-3.6-.9-6.75.45-9.45 4.05zM0 38.3c1.8-7.2 6.3-10.8 13.5-10.8 10.8 0 12.15 8.1 17.55 9.45 3.6.9 6.75-.45 9.45-4.05-1.8 7.2-6.3 10.8-13.5 10.8-10.8 0-12.15-8.1-17.55-9.45-3.6-.9-6.75.45-9.45 4.05z" />
            </svg>
          </NavLink>
          <NavLink to="/">
            <span className="font-semibold text-l tracking-tight">
              masks for Docs
            </span>
          </NavLink>
        </div>
        <div className="block lg:hidden">
          <button
            onClick={toggleMenu}
            className="flex items-center px-3 py-2 border rounded border-white focus:outline-none">
            <svg
              className="fill-current h-3 w-3"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg">
              <title>Menu</title>
              <path d="M0 3h20v2H0V3zm0 6h20v2H0V9zm0 6h20v2H0v-2z" />
            </svg>
          </button>
        </div>
        <div
          className={`w-full ${
            menuOpen ? 'block' : 'hidden'
          } flex-grow lg:flex lg:items-center lg:w-auto`}>
          <div className="text-sm lg:flex-grow">
            <MyNavLink onClick={hideMenu} to="/about" label="About Us" />
            <MyNavLink onClick={hideMenu} to="/news" label="News" />
            <MyNavLink onClick={hideMenu} to="/involved" label="Get Involved" />
            <MyNavLink onClick={hideMenu} to="/supplies" label="Get Supplies" />
            <MyNavLink
              onClick={hideMenu}
              to="/chapters"
              label="Local Chapters"
            />
            <MyNavLink onClick={hideMenu} to="/resources" label="Resources" />
            <MyNavLink onClick={hideMenu} to="/faq" label="FAQ" />
          </div>
          <div>
            <a
              href="/donate"
              className="bg-pink-500 inline-block text-sm px-4 py-2 leading-none rounded hover:border-transparent hover:text-teal-500 hover:bg-white mt-4 lg:mt-0">
              Donate
            </a>
          </div>
        </div>
      </nav>
    </header>
  )
}

const MyNavLink: React.FC<{
  onClick?: () => any
  to: string
  label: string
}> = ({ to, label, onClick }) => (
  <NavLink
    onClick={onClick}
    activeClassName="text-pink-400"
    to={to}
    className="block mt-4 lg:inline-block lg:mt-0 hover:text-pink-300 mr-9">
    {label}
  </NavLink>
)
