import { useAuth0 } from '@auth0/auth0-react'
import React, { useCallback, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { NavLink } from 'react-router-dom'

function SessionButton() {
  const { isAuthenticated, loginWithRedirect, logout, user } = useAuth0()

  return isAuthenticated ?
    <button onClick={() => {
      logout({ returnTo: window.location.origin })
    }}>Log out {user.given_name}</button>
       : (
    <button onClick={loginWithRedirect}>Log in</button>
  )
}

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
      <nav className="flex flex-row items-center justify-between flex-wrap flex-shrink-0 w-full mx-auto bg-da-dark-gray font-heading text-white p-2">
        <button
          onClick={toggleMenu}
          data-cy="toggle-menu"
          className="lg:hidden flex items-center px-3 py-2 focus:outline-none">
          <svg
            width="18"
            height="17"
            viewBox="0 0 18 17"
            fill="none"
            xmlns="http://www.w3.org/2000/svg">
            <title>{t('navBar.toggleMenu')}</title>

            <path
              d="M1.8 3.27407H16.2C17.19 3.27407 18 2.53741 18 1.63704C18 0.736667 17.19 0 16.2 0H1.8C0.81 0 0 0.736667 0 1.63704C0 2.53741 0.81 3.27407 1.8 3.27407ZM16.2 13.7259H1.8C0.81 13.7259 0 14.4626 0 15.363C0 16.2633 0.81 17 1.8 17H16.2C17.19 17 18 16.2633 18 15.363C18 14.4626 17.19 13.7259 16.2 13.7259ZM16.2 6.86296H1.8C0.81 6.86296 0 7.59963 0 8.5C0 9.40037 0.81 10.137 1.8 10.137H16.2C17.19 10.137 18 9.40037 18 8.5C18 7.59963 17.19 6.86296 16.2 6.86296Z"
              fill="white"
            />
          </svg>
        </button>

        <a
          className="flex items-center flex-shrink-0 lg:ml-4 lg:mr-9 flex-grow lg:flex-grow-0"
          href="https://example.com">
          <img
            src="http://www.fillmurray.com/40/40"
            alt="Distribute Aid logo"
          />
        </a>

        <div
          className={`w-full ${
            menuOpen ? 'block' : 'hidden'
          } lg:ml-8 flex-grow lg:flex lg:items-center lg:w-auto flex-shrink-0`}>
          <div className="text-sm pb-4 lg:pb-0 lg:flex-grow flex-shrink-0">
            <HeaderNavLink onClick={hideMenu} to="http://example.com">
              Distribute Aid Toolbox
            </HeaderNavLink>
          </div>
        </div>

        <SessionButton />

        <a
          href="/account"
          rel="noopener noreferrer"
          target="_blank"
          className="
            'font-mono block text-base sm:text-lg leading-none hover:border-transparent px-4 py-2 sm:px-6 sm:py-3">
          {t('navBar.accountLink')}
        </a>
      </nav>
    </header>
  )
}

const HeaderNavLink: React.FC<{
  onClick?: () => void
  to: string
}> = ({ to, children, onClick, ...rest }) => {
  const className =
    'block text-xl mt-4 lg:inline-block lg:mt-0 cursor-pointer mr-12'
  if (to.startsWith('http')) {
    return (
      <a href={to} className={className} onClick={onClick} {...rest}>
        {children}
      </a>
    )
  }

  return (
    <NavLink
      onClick={onClick}
      to={to}
      activeClassName="fix-me"
      className={className}
      {...rest}>
      {children}
    </NavLink>
  )
}
