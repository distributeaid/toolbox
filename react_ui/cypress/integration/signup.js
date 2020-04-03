describe('Sign up', () => {
  it('use sign up link', () => {
    cy.visit('/')
    cy.get('[data-cy=sign-up-link]').click()
    cy.url().should('match', /sign-up/)
  })
  it('fill form', () => {
    const emailInput = cy.get('#signup_email')
    emailInput.type('alex@example.com')
    const passwordInput = cy.get('#signup_password')
    passwordInput.type('FooB@r42!')
    const button = cy.get('[data-cy=signup-button]')
    button.click()
    console.log(button)
    button.should('be.disabled')
    emailInput.should('be.disabled')
    passwordInput.should('be.disabled')
  })
})
