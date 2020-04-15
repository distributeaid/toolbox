import React from 'react'
import { useTranslation } from 'react-i18next'

import { classnames } from './classnames'

type Props = {
  onClick?: () => void
  className?: string
}

export const DonateButton: React.FC<Props> = ({ onClick, className }) => {
  const { t } = useTranslation()

  return (
    <a
      href="https://masksfordocs.com/donate"
      rel="noopener noreferrer"
      target="_blank"
      onClick={onClick}
      className={classnames(
        'font-mono bg-mfd-pink-1 block text-lg font-bold leading-none rounded hover:border-transparent hover:text-mfd-pink-1 hover:bg-white px-6 py-3',
        className
      )}>
      {t('navBar.donateLink')}
    </a>
  )
}
