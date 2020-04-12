import React from 'react'

import { AuthLink } from '../../auth/AuthLink'
import { MainContent } from '../MainContent'

export const SubNav: React.FC = () => (
  <MainContent>
    <div className="mx-auto max-w-7xl flex flex-row justify-end p-4 text-xs font-body">
      <AuthLink />
    </div>
  </MainContent>
)
