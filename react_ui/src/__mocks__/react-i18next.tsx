import React from 'react'

export const useTranslation = () => {
  return { t: jest.fn().mockImplementation((v) => v) }
}

export const Trans = ({ children }: React.PropsWithChildren<{}>) => (
  <>{children}</>
)
