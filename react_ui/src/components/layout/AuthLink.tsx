import React from 'react'
import { useTranslation } from 'react-i18next'
import { NavLink } from 'react-router-dom'

import { useAuthState } from '../../auth/useAuthState'

export const AuthLink: React.FC = () => {
  const { t } = useTranslation()
  const { authState, signOut } = useAuthState()

  return (
    <div className="cursor-pointer relative z-10">
      {authState === 'anonymous' && (
        <NavLink to="/sign-in" data-cy="sign-up-link">
          {t('auth.signIn')}
        </NavLink>
      )}
      {authState === 'authenticated' && (
        <span onClick={signOut}>{t('auth.signOut')}</span>
      )}
    </div>
  )
}
