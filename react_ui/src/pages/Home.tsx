import React, { useState } from 'react'

import { classnames } from '../components/classnames'
import { ContentContainer } from '../components/ContentContainer'

export const Home: React.FC = () => {
  const [isOpen, setOpen] = useState(false)
  let sideBarDummyContents = ''
  for (let i = 0; i < 300; i++) sideBarDummyContents += i + ' '

  return (
    <ContentContainer>
      <div>
        <h1 className="font-bold text-3xl m-6">Shipments</h1>

        <button
          className="m-6"
          onClick={() => (isOpen ? setOpen(false) : setOpen(true))}>
          {isOpen ? 'Close' : 'Open'}
        </button>
      </div>

      <div
        className={classnames(
          'sidebar z-40 p-6',
          isOpen && 'sidebar--open',
          'sidebar--closed' && !isOpen
        )}>
        {sideBarDummyContents}
      </div>
    </ContentContainer>
  )
}
