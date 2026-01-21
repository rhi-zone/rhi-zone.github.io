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
            { text: 'Hypha', link: 'https://rhizome-lab.github.io/hypha/' },
            { text: 'Resin', link: 'https://rhizome-lab.github.io/resin/' },
            { text: 'Frond', link: 'https://rhizome-lab.github.io/frond/' },
            { text: 'Dew', link: 'https://rhizome-lab.github.io/dew/' },
            { text: 'Liana', link: 'https://rhizome-lab.github.io/liana/' },
            { text: 'Cambium', link: 'https://rhizome-lab.github.io/cambium/' },
            { text: 'Canopy', link: 'https://rhizome-lab.github.io/canopy/' },
            { text: 'Siphon', link: 'https://rhizome-lab.github.io/siphon/' },
            { text: 'Nursery', link: 'https://rhizome-lab.github.io/nursery/' },
            { text: 'Spore', link: 'https://rhizome-lab.github.io/spore/' },
            { text: 'Pith', link: 'https://rhizome-lab.github.io/pith/' },
            { text: 'Flora', link: 'https://rhizome-lab.github.io/flora/' },
            { text: 'Trellis', link: 'https://rhizome-lab.github.io/trellis/' },
          ]
        },
      ],

      sidebar: {
        '/': [
          {
            text: 'Overview',
            items: [
              { text: 'About', link: '/about' },
              { text: 'Vision', link: '/vision' },
              { text: 'Architecture', link: '/architecture' },
              { text: 'Integration', link: '/integration' },
            ]
          },
          {
            text: 'Projects',
            items: [
              { text: 'Moss', link: '/projects/moss' },
              { text: 'Hypha', link: '/projects/hypha' },
              { text: 'Resin', link: '/projects/resin' },
              { text: 'Frond', link: '/projects/frond' },
              { text: 'Dew', link: '/projects/dew' },
              { text: 'Liana', link: '/projects/liana' },
              { text: 'Cambium', link: '/projects/cambium' },
              { text: 'Canopy', link: '/projects/canopy' },
              { text: 'Siphon', link: '/projects/siphon' },
              { text: 'Nursery', link: '/projects/nursery' },
              { text: 'Spore', link: '/projects/spore' },
              { text: 'Pith', link: '/projects/pith' },
              { text: 'Flora', link: '/projects/flora' },
              { text: 'Trellis', link: '/projects/trellis' },
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
