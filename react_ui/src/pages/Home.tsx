import React from 'react'
import { useTranslation } from 'react-i18next'

import { ContentContainer } from '../components/ContentContainer'

export const Home: React.FC = () => {
  const { t } = useTranslation()

  return (
    <ContentContainer>
      <div className="grid grid-cols-1 gap-4 m-16">
        <h1 className="font-bold text-3xl mb-6">{t('home.pageTitle')}</h1>

        <p>{t('home.subhead')}</p>
      </div>
    </ContentContainer>
  )
}
