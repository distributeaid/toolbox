import React from "react"

import { Button } from "../components/Button"
import { Checkbox } from "../components/Checkbox"
import { ContentContainer } from "../components/ContentContainer"
import { Divider } from "../components/Divider"
import { Input } from "../components/Input"
import {TextLink} from "../components/TextLink"

const StyleGuide: React.FC = () => (
  <ContentContainer>
    <div className="grid grid-cols-1 gap-4 m-16">
      <Button title="Default Button" />

      <Divider outerClasses="m-4">A Divider, margin: m-4</Divider>

      <Checkbox title="A Checkbox" id="checkbox" />

      <Divider outerClasses="m-4">A Divider, margin: m-4</Divider>

      <Input
        id="demo"
        type="text"
        title="Input, type: text"
        onChange={event => null}
      />

      <Divider outerClasses="m-4">A Divider, margin: m-4</Divider>

      <TextLink href="http://www.example.com">Example Link</TextLink>
    </div>
  </ContentContainer>
)

export default StyleGuide
