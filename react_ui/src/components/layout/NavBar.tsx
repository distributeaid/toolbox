import React, { useCallback, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { NavLink } from 'react-router-dom'

import { M4DLogo } from './M4DLogo'

const showStyleguide = process.env.NODE_ENV === 'development'

export const NavBar: React.FC = () => {
  const { t } = useTranslation()
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
              <title>{t('navBar.toggleMenu')}</title>
              <path d="M0 3h20v2H0V3zm0 6h20v2H0V9zm0 6h20v2H0v-2z" />
            </svg>
          </button>
        </div>
        <div
          className={`w-full ${
            menuOpen ? 'block' : 'hidden'
          } flex-grow lg:flex lg:items-center lg:w-auto`}>
          <div className="text-sm lg:flex-grow">
            <HeaderNavLink onClick={hideMenu} to="/about">
              {t('navBar.aboutLink')}
            </HeaderNavLink>
            <HeaderNavLink onClick={hideMenu} to="/news">
              {t('navBar.newsLink')}
            </HeaderNavLink>
            <HeaderNavLink onClick={hideMenu} to="/involved">
              {t('navBar.getInvolvedLink')}
            </HeaderNavLink>
            <HeaderNavLink onClick={hideMenu} to="/supplies">
              {t('navBar.suppliesLink')}
            </HeaderNavLink>
            <HeaderNavLink onClick={hideMenu} to="/chapters">
              {t('navBar.chaptersLink')}
            </HeaderNavLink>
            <HeaderNavLink onClick={hideMenu} to="/resources">
              {t('navBar.resourcesLink')}
            </HeaderNavLink>
            <HeaderNavLink onClick={hideMenu} to="/faq">
              {t('navBar.faqLink')}
            </HeaderNavLink>
            {showStyleguide && (
              <HeaderNavLink onClick={hideMenu} to="/style-guide">
                {t('navBar.styleGuideLink')}
              </HeaderNavLink>
            )}
          </div>
          <div>
            <NavLink
              to="/donate"
              onClick={hideMenu}
              className="bg-pink-500 inline-block text-sm px-4 py-2 leading-none rounded hover:border-transparent hover:text-teal-500 hover:bg-white mt-4 lg:mt-0">
              {t('navBar.donateLink')}
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
}> = ({ to, children, onClick, ...rest }) => (
  <NavLink
    onClick={onClick}
    to={to}
    activeClassName="text-pink-400"
    className={navLinkClassName}
    {...rest}>
    {children}
  </NavLink>
)
