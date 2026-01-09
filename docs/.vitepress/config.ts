import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

export default withMermaid(
  defineConfig({
    title: 'Rhizome',
    description: 'Tools for programmable creativity',

    themeConfig: {
      nav: [
        { text: 'Home', link: '/' },
        { text: 'About', link: '/about' },
        { text: 'Projects', link: '/projects/' },
        {
          text: 'Docs',
          items: [
            { text: 'Moss', link: 'https://rhizome-lab.github.io/moss/' },
            { text: 'Lotus', link: 'https://rhizome-lab.github.io/lotus/' },
            { text: 'Resin', link: 'https://rhizome-lab.github.io/resin/' },
            { text: 'Sap', link: 'https://rhizome-lab.github.io/sap/' },
            { text: 'Liana', link: 'https://rhizome-lab.github.io/liana/' },
            { text: 'Cambium', link: 'https://rhizome-lab.github.io/cambium/' },
            { text: 'Canopy', link: 'https://rhizome-lab.github.io/canopy/' },
          ]
        },
      ],

      sidebar: {
        '/': [
          {
            text: 'Overview',
            items: [
              { text: 'About', link: '/about' },
              { text: 'Architecture', link: '/architecture' },
              { text: 'Integration', link: '/integration' },
            ]
          },
          {
            text: 'Projects',
            items: [
              { text: 'Moss', link: '/projects/moss' },
              { text: 'Lotus', link: '/projects/lotus' },
              { text: 'Resin', link: '/projects/resin' },
              { text: 'Sap', link: '/projects/sap' },
              { text: 'Liana', link: '/projects/liana' },
              { text: 'Cambium', link: '/projects/cambium' },
              { text: 'Canopy', link: '/projects/canopy' },
            ]
          },
          {
            text: 'Community',
            items: [
              { text: 'Contributing', link: '/contributing' },
            ]
          },
        ]
      },

      socialLinks: [
        { icon: 'github', link: 'https://github.com/rhizome-lab' }
      ],

      search: {
        provider: 'local'
      },
    },

    vite: {
      optimizeDeps: {
        include: ['mermaid'],
      },
    },
  }),
)
