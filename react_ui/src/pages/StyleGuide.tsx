import React from 'react'
import { Trans, useTranslation } from 'react-i18next'

import { Button } from '../components/Button'
import { Checkbox } from '../components/Checkbox'
import { ContentContainer } from '../components/ContentContainer'
import { Divider } from '../components/Divider'
import { Input } from '../components/Input'
import { TextLink } from '../components/TextLink'

const StyleGuide: React.FC = () => {
  const { t } = useTranslation()

  return (
    <ContentContainer>
      <div className="grid grid-cols-1 gap-4 m-16">
        <h1 className="font-bold text-3xl mb-6">{t('styleguide.title')}</h1>

        <Button title="Default Button" />

        <Divider outerClasses="m-4">A Divider, margin: m-4</Divider>

        <Checkbox title="A Checkbox" id="checkbox" />

        <Divider outerClasses="m-4">A Divider, margin: m-4</Divider>

        <Input
          id="demo"
          type="text"
          title="Input, type: text"
          onChange={(event) => null}
        />

        <Divider outerClasses="m-4">A Divider, margin: m-4</Divider>

        <p>
          {
            // Translating text that contains multiple react nodes can be
            // tricky, see https://react.i18next.com/latest/trans-component
            // for more info.
          }
          <Trans i18nKey="styleguide.linkExample">
            Here is a translated{' '}
            <TextLink href="http://www.example.com">Example Link</TextLink> with
            a few different <strong>react</strong> nodes.
          </Trans>
        </p>
      </div>
    </ContentContainer>
  )
}

export default StyleGuide
