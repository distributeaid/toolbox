import countries from '../data/countries.json'
import usStates from '../data/us_states.json'

type PlaceMap = Record<string, string | undefined>

const countryCodeToNameMap = countries.reduce((table, { name, code }) => {
  table[code] = name
  return table
}, {} as PlaceMap)

countryCodeToNameMap['US'] = 'USA'

export const countryCodeToName = (code: string) => countryCodeToNameMap[code]

const usStateCodeToNameMap = usStates.reduce((states, { name, code }) => {
  states[code] = name
  return states
}, {} as PlaceMap)

export const usStateCodeToName = (code: string) => usStateCodeToNameMap[code]
