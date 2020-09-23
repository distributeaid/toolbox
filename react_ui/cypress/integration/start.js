describe('Start Page', () => {
  it('successfully loads', () => {
    cy.visit('http://localhost:3000')
  })
  it('redirects to the list of groups', () => {
    cy.url().should('match', /chapters/)
  })
})
