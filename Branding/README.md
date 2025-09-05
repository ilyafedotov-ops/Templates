# Corporate Branding and Identity Management Guide

This comprehensive guide provides enterprise-grade branding configuration and management capabilities for security assessment reports. It enables professional, consistent, and compliant report production for consulting organizations serving multiple enterprise clients.

## Table of Contents

1. [Overview](#overview)
2. [Branding Configuration](#branding-configuration)
3. [Logo and Visual Identity](#logo-and-visual-identity)
4. [Color Schemes and Typography](#color-schemes-and-typography)
5. [Report Template Customization](#report-template-customization)
6. [Multi-Client Configuration Management](#multi-client-configuration-management)
7. [Brand Asset Organization](#brand-asset-organization)
8. [Quality Assurance and Compliance](#quality-assurance-and-compliance)
9. [Integration Workflows](#integration-workflows)
10. [Version Control and Change Management](#version-control-and-change-management)
11. [Accessibility and Responsive Design](#accessibility-and-responsive-design)
12. [Brand Enforcement and Validation](#brand-enforcement-and-validation)
13. [Troubleshooting](#troubleshooting)

## Overview

The branding system supports multiple enterprise clients with distinct brand requirements while maintaining consistency and professional quality across all security assessment deliverables. This framework enables:

- **Professional Customization**: Enterprise-grade report branding for client deliverables
- **Brand Consistency**: Standardized application of corporate identity elements
- **Multi-Client Support**: Simultaneous management of multiple client brand configurations
- **Quality Assurance**: Automated validation of brand compliance and asset quality
- **Workflow Integration**: Seamless integration with report generation pipelines

### Key Components

```
Branding/
├── README.md                    # This comprehensive guide
├── branding.yaml               # Primary brand configuration
├── clients/                    # Multi-client configurations
│   ├── client-a/              # Client-specific brand assets
│   ├── client-b/              # Client-specific brand assets
│   └── templates/             # Client configuration templates
├── assets/                     # Brand asset library
│   ├── logos/                 # Logo variations and formats
│   ├── fonts/                 # Typography assets
│   ├── colors/                # Color palette definitions
│   └── templates/             # Report template variations
├── validation/                 # Brand validation tools
└── docs/                      # Extended documentation
```

## Branding Configuration

### Primary Configuration File

The `branding.yaml` file serves as the central configuration for all branding elements:

```yaml
# Primary Brand Configuration
brand:
  # Organization Details
  organization:
    name: "Your Organization Name"
    legal_name: "Your Organization Legal Name, Inc."
    tagline: "Securing Digital Transformation"
    website: "https://www.yourorganization.com"
    
  # Contact Information
  contacts:
    primary:
      name: "John Smith"
      title: "Chief Security Officer"
      email: "j.smith@yourorganization.com"
      phone: "+1 (555) 123-4567"
    secondary:
      name: "Jane Doe"
      title: "Security Practice Lead"
      email: "j.doe@yourorganization.com"
      phone: "+1 (555) 123-4568"
  
  # Document Classification
  classification:
    default: "CONFIDENTIAL"
    levels: ["PUBLIC", "INTERNAL", "CONFIDENTIAL", "RESTRICTED"]
    watermark: true
    
  # Visual Identity
  visual:
    logo:
      primary: "assets/logos/logo-primary.svg"
      secondary: "assets/logos/logo-secondary.png"
      monochrome: "assets/logos/logo-mono.png"
      favicon: "assets/logos/favicon.ico"
    
    colors:
      primary: "#1B365D"      # Deep Blue
      secondary: "#4A90A4"    # Teal
      accent: "#7FB069"       # Green
      neutral_dark: "#2D3748" # Dark Gray
      neutral_light: "#F7FAFC" # Light Gray
      text_primary: "#1A202C" # Near Black
      text_secondary: "#718096" # Medium Gray
      
    typography:
      primary_font: "Roboto"
      heading_font: "Roboto Slab"
      monospace_font: "Source Code Pro"
      
  # Report Configuration
  reports:
    header_height: "80px"
    footer_height: "60px"
    margin: "1in"
    page_numbering: true
    toc_depth: 3
    
# Client-Specific Overrides (when applicable)
client:
  enabled: false
  config_path: ""
  
# Validation Settings
validation:
  logo_max_size: "5MB"
  required_formats: ["SVG", "PNG"]
  min_resolution: "300dpi"
  color_accuracy: "sRGB"
```

### Environment-Specific Configurations

Create environment-specific configurations for different deployment contexts:

```yaml
# branding-development.yaml
extends: "branding.yaml"
brand:
  visual:
    colors:
      primary: "#FF6B35"  # Orange for development
  classification:
    default: "DEVELOPMENT"
    watermark: true
    watermark_text: "DEVELOPMENT - NOT FOR DISTRIBUTION"

# branding-staging.yaml  
extends: "branding.yaml"
brand:
  visual:
    colors:
      primary: "#9B59B6"  # Purple for staging
  classification:
    default: "STAGING"
```

## Logo and Visual Identity

### Logo Specifications

#### File Formats and Requirements

| Format | Use Case | Specifications |
|--------|----------|----------------|
| **SVG** | Digital, scalable | Vector format, max 2MB, sRGB color space |
| **PNG** | Digital, raster | 300 DPI minimum, transparent background |
| **JPG** | Print, photos | 300 DPI minimum, white background |
| **PDF** | Print, vector | Vector format, CMYK color space |
| **ICO** | Favicon | 16x16, 32x32, 48x48 px sizes |

#### Logo Variations

```
assets/logos/
├── primary/
│   ├── logo-primary.svg        # Full color, horizontal
│   ├── logo-primary-vertical.svg # Full color, stacked
│   ├── logo-primary-square.svg  # Full color, square format
│   └── logo-primary.png        # Raster version (300 DPI)
├── secondary/
│   ├── logo-secondary.svg      # Alternative color scheme
│   └── logo-secondary.png      # Raster version
├── monochrome/
│   ├── logo-mono-black.svg     # Black version
│   ├── logo-mono-white.svg     # White version (reversed)
│   └── logo-mono-gray.svg      # Gray version
├── print/
│   ├── logo-cmyk.pdf          # CMYK for print
│   └── logo-pantone.pdf       # Pantone color version
└── favicon/
    ├── favicon.ico            # Multi-size ICO
    ├── favicon-16x16.png      # 16px PNG
    ├── favicon-32x32.png      # 32px PNG
    └── apple-touch-icon.png   # 180px for iOS
```

#### Logo Usage Guidelines

**Clear Space Requirements:**
- Minimum clear space: 1/2 the height of the logo on all sides
- Never place other elements within the clear space area

**Minimum Size Requirements:**
- Digital: 120px width minimum
- Print: 1 inch width minimum
- Favicon: 16px readable

**Prohibited Uses:**
- Never stretch or distort the logo
- Never change logo colors outside approved palette
- Never add effects (drop shadows, gradients, etc.)
- Never place on busy backgrounds without sufficient contrast

### Brand Mark Guidelines

```yaml
# Brand mark specifications
brand_mark:
  clear_space:
    minimum: "0.5x logo height"
    preferred: "1x logo height"
  
  minimum_sizes:
    digital: "120px"
    print: "1in"
    business_card: "0.5in"
    
  placement:
    preferred_positions: ["top-left", "top-center", "bottom-center"]
    avoid_positions: ["bottom-left", "center-overlap"]
    
  backgrounds:
    light: 
      use: ["primary", "secondary", "monochrome-black"]
      contrast_ratio: ">= 4.5:1"
    dark:
      use: ["monochrome-white", "secondary-light"]
      contrast_ratio: ">= 4.5:1"
```

## Color Schemes and Typography

### Color Palette Specifications

#### Primary Color Palette

```css
/* Primary Brand Colors */
:root {
  --color-primary: #1B365D;        /* Deep Blue - Primary brand */
  --color-secondary: #4A90A4;      /* Teal - Secondary brand */
  --color-accent: #7FB069;         /* Green - Accent/success */
  
  /* Neutral Colors */
  --color-neutral-dark: #2D3748;   /* Dark gray - headers */
  --color-neutral-medium: #718096;  /* Medium gray - body text */
  --color-neutral-light: #F7FAFC;  /* Light gray - backgrounds */
  
  /* Status Colors */
  --color-success: #38A169;        /* Success states */
  --color-warning: #D69E2E;        /* Warning states */
  --color-error: #E53E3E;          /* Error states */
  --color-info: #3182CE;           /* Informational states */
}
```

#### Color Usage Matrix

| Color | Primary Use | Secondary Use | Accessibility |
|-------|-------------|---------------|---------------|
| Deep Blue (#1B365D) | Headers, navigation | Buttons, links | AA compliant on white |
| Teal (#4A90A4) | Subheadings, accents | Icons, borders | AA compliant on white |
| Green (#7FB069) | Success indicators | Positive metrics | AA compliant on white |
| Dark Gray (#2D3748) | Body text | Table headers | AAA compliant on white |
| Medium Gray (#718096) | Secondary text | Captions | AA compliant on white |

#### Color Accessibility Compliance

```yaml
accessibility:
  contrast_ratios:
    normal_text: 4.5  # WCAG AA standard
    large_text: 3.0   # WCAG AA standard
    enhanced: 7.0     # WCAG AAA standard
    
  color_blind_safe: true
  high_contrast_mode: supported
  
  testing:
    tools: ["WAVE", "axe-core", "Color Oracle"]
    validation: "automated"
```

### Typography System

#### Font Specifications

```yaml
typography:
  fonts:
    primary:
      name: "Roboto"
      weights: [300, 400, 500, 700]
      formats: ["woff2", "woff", "ttf"]
      fallback: ["Arial", "Helvetica", "sans-serif"]
      
    heading:
      name: "Roboto Slab"
      weights: [400, 500, 700]
      formats: ["woff2", "woff", "ttf"]
      fallback: ["Georgia", "Times", "serif"]
      
    monospace:
      name: "Source Code Pro"
      weights: [400, 500, 600]
      formats: ["woff2", "woff", "ttf"]
      fallback: ["Consolas", "Monaco", "monospace"]
      
  scales:
    base_size: "16px"
    line_height: 1.6
    scale_ratio: 1.25  # Major Third
    
  sizes:
    h1: "2.488rem"    # 39.81px
    h2: "2.074rem"    # 33.18px
    h3: "1.728rem"    # 27.65px
    h4: "1.44rem"     # 23.04px
    h5: "1.2rem"      # 19.2px
    h6: "1rem"        # 16px
    body: "1rem"      # 16px
    small: "0.833rem" # 13.33px
    caption: "0.694rem" # 11.11px
```

#### Typography Usage Guidelines

```css
/* Report Typography Styles */
.report-title {
  font-family: var(--font-heading);
  font-size: var(--size-h1);
  font-weight: 700;
  color: var(--color-primary);
  line-height: 1.2;
  margin-bottom: 1.5rem;
}

.section-header {
  font-family: var(--font-heading);
  font-size: var(--size-h2);
  font-weight: 500;
  color: var(--color-primary);
  border-bottom: 2px solid var(--color-accent);
  padding-bottom: 0.5rem;
  margin-bottom: 1rem;
}

.body-text {
  font-family: var(--font-primary);
  font-size: var(--size-body);
  font-weight: 400;
  color: var(--color-neutral-dark);
  line-height: 1.6;
}

.code-block {
  font-family: var(--font-monospace);
  font-size: 0.875rem;
  background: var(--color-neutral-light);
  border-left: 4px solid var(--color-accent);
  padding: 1rem;
  margin: 1rem 0;
}
```

## Report Template Customization

### Template Architecture

The report template system uses a hierarchical structure allowing for brand customization at multiple levels:

```
Report/
├── templates/
│   ├── base/              # Base template structure
│   │   ├── layout.html    # Page layout and structure
│   │   ├── styles.css     # Base styling
│   │   └── components/    # Reusable components
│   ├── branded/           # Brand-specific templates
│   │   ├── executive/     # Executive summary template
│   │   ├── technical/     # Technical report template
│   │   └── compliance/    # Compliance report template
│   └── client-specific/   # Client customizations
├── components/
│   ├── headers/           # Header variations
│   ├── footers/           # Footer variations
│   ├── cover-pages/       # Cover page designs
│   └── tables/            # Table styling
└── assets/
    ├── css/              # Compiled stylesheets
    ├── js/               # Interactive elements
    └── images/           # Template images
```

### Customization Workflow

#### 1. Template Selection

```yaml
# template-config.yaml
template:
  type: "compliance"        # executive, technical, compliance
  format: "pdf"            # pdf, html, docx
  layout: "professional"   # professional, minimal, detailed
  
  customizations:
    cover_page: true
    table_of_contents: true
    executive_summary: true
    appendices: true
    
  branding:
    client_override: false
    watermark: true
    page_numbering: "footer-right"
    
  sections:
    - "executive_summary"
    - "scope_and_methodology"
    - "findings_summary"
    - "detailed_findings"
    - "recommendations"
    - "remediation_roadmap"
    - "appendices"
```

#### 2. Style Customization

```scss
// Custom report styling
@import 'branding-variables';
@import 'typography';
@import 'colors';

.report-container {
  font-family: $font-primary;
  color: $color-text-primary;
  
  .cover-page {
    background: linear-gradient(135deg, $color-primary, $color-secondary);
    color: white;
    padding: 2rem;
    
    .logo {
      max-height: 80px;
      margin-bottom: 2rem;
    }
    
    .title {
      font-size: 2.5rem;
      font-weight: 700;
      margin-bottom: 1rem;
    }
  }
  
  .page-header {
    border-bottom: 3px solid $color-accent;
    padding-bottom: 1rem;
    margin-bottom: 2rem;
    
    .logo {
      height: 40px;
      float: left;
    }
    
    .document-info {
      float: right;
      font-size: 0.9rem;
      color: $color-text-secondary;
    }
  }
  
  .findings {
    .critical { border-left: 4px solid $color-error; }
    .high { border-left: 4px solid $color-warning; }
    .medium { border-left: 4px solid $color-info; }
    .low { border-left: 4px solid $color-success; }
  }
}
```

#### 3. Component Customization

```html
<!-- Custom header component -->
<header class="report-header">
  <div class="header-content">
    <div class="logo-section">
      <img src="{{ brand.visual.logo.primary }}" 
           alt="{{ brand.organization.name }}" 
           class="company-logo">
    </div>
    <div class="document-info">
      <h1 class="document-title">{{ document.title }}</h1>
      <p class="classification {{ document.classification | lower }}">
        {{ document.classification }}
      </p>
      <p class="document-date">{{ document.date | date: '%B %d, %Y' }}</p>
    </div>
  </div>
</header>
```

### Template Validation

```yaml
# template-validation.yaml
validation:
  structure:
    required_sections: ["cover", "toc", "executive_summary", "findings"]
    optional_sections: ["appendices", "glossary"]
    
  styling:
    css_validation: true
    accessibility_check: true
    brand_compliance: true
    
  content:
    placeholder_check: true
    broken_links: false
    image_optimization: true
    
  output:
    pdf_generation: "wkhtmltopdf"
    pdf_options:
      page_size: "A4"
      orientation: "Portrait"
      margin_top: "1in"
      margin_bottom: "1in"
      margin_left: "0.75in"
      margin_right: "0.75in"
```

## Multi-Client Configuration Management

### Client Configuration Structure

```
clients/
├── templates/
│   ├── default-client.yaml      # Default client template
│   └── enterprise-client.yaml   # Enterprise client template
├── active/
│   ├── client-alpha/
│   │   ├── branding.yaml       # Client-specific branding
│   │   ├── assets/             # Client assets
│   │   └── templates/          # Customized templates
│   ├── client-beta/
│   │   ├── branding.yaml
│   │   ├── assets/
│   │   └── templates/
│   └── client-gamma/
└── archived/                   # Archived client configurations
```

### Client Configuration Template

```yaml
# clients/templates/enterprise-client.yaml
client:
  # Client Information
  info:
    name: "Client Name"
    code: "CLIENT_CODE"        # Used for file naming
    type: "enterprise"         # enterprise, mid-market, startup
    tier: "platinum"           # platinum, gold, silver
    
  # Brand Override Settings
  branding:
    use_client_brand: true
    co_branding: false         # Show both logos
    
    # Client Brand Assets
    assets:
      logo_primary: "assets/logos/client-logo.svg"
      logo_secondary: "assets/logos/client-logo-alt.png"
      favicon: "assets/favicon/client-favicon.ico"
      
    # Color Customization
    colors:
      primary: "#003366"       # Client primary color
      secondary: "#0066CC"     # Client secondary color
      accent: "#66CC00"        # Client accent color
      
    # Typography Override
    typography:
      primary_font: "Client Custom Font"
      heading_font: "Client Header Font"
      
  # Report Customization
  reports:
    template: "enterprise"
    classification_override: "CLIENT CONFIDENTIAL"
    footer_text: "Property of {{ client.info.name }}"
    
    # Custom Sections
    sections:
      disclaimer: true
      client_background: true
      custom_appendices: ["compliance_matrix", "glossary"]
      
  # Contact Overrides
  contacts:
    primary:
      name: "Client Contact Name"
      title: "Chief Security Officer"
      email: "security@client.com"
    project_manager:
      name: "Project Manager"
      email: "pm@yourorg.com"
      
  # Compliance Requirements
  compliance:
    frameworks: ["SOC2", "ISO27001", "NIST"]
    evidence_retention: "7 years"
    encryption_required: true
```

### Client Selection and Activation

```bash
#!/bin/bash
# scripts/activate-client.sh

CLIENT_CODE=$1
CLIENT_CONFIG="clients/active/${CLIENT_CODE}/branding.yaml"

if [ ! -f "$CLIENT_CONFIG" ]; then
    echo "Error: Client configuration not found for ${CLIENT_CODE}"
    exit 1
fi

# Backup current configuration
cp branding.yaml branding.yaml.backup

# Merge client configuration with base configuration
python scripts/merge-branding.py \
    --base branding.yaml \
    --client "$CLIENT_CONFIG" \
    --output branding-active.yaml

# Validate merged configuration
python scripts/validate-branding.py branding-active.yaml

if [ $? -eq 0 ]; then
    mv branding-active.yaml branding.yaml
    echo "Client ${CLIENT_CODE} configuration activated successfully"
else
    echo "Error: Client configuration validation failed"
    mv branding.yaml.backup branding.yaml
    exit 1
fi
```

### Multi-Client Report Generation

```python
#!/usr/bin/env python3
# scripts/generate-report.py

import yaml
import jinja2
from pathlib import Path

class ClientReportGenerator:
    def __init__(self, client_code=None):
        self.base_config = self.load_config('branding.yaml')
        self.client_config = None
        
        if client_code:
            client_path = f'clients/active/{client_code}/branding.yaml'
            if Path(client_path).exists():
                self.client_config = self.load_config(client_path)
                self.config = self.merge_configs(self.base_config, self.client_config)
            else:
                raise FileNotFoundError(f"Client configuration not found: {client_path}")
        else:
            self.config = self.base_config
    
    def load_config(self, path):
        with open(path, 'r') as f:
            return yaml.safe_load(f)
    
    def merge_configs(self, base, client):
        """Deep merge client config over base config"""
        merged = base.copy()
        
        if 'client' in client:
            # Apply client-specific overrides
            client_brand = client['client'].get('branding', {})
            
            # Override colors
            if 'colors' in client_brand:
                merged['brand']['visual']['colors'].update(client_brand['colors'])
            
            # Override assets
            if 'assets' in client_brand:
                merged['brand']['visual']['logo'].update(client_brand['assets'])
                
            # Override contacts
            if 'contacts' in client['client']:
                merged['brand']['contacts'].update(client['client']['contacts'])
        
        return merged
    
    def generate_report(self, template_name, output_path):
        """Generate report using client-specific configuration"""
        env = jinja2.Environment(
            loader=jinja2.FileSystemLoader('Report/templates')
        )
        
        template = env.get_template(f'{template_name}.html')
        
        rendered = template.render(
            brand=self.config['brand'],
            client=self.client_config.get('client', {}) if self.client_config else {},
            timestamp=datetime.now().isoformat()
        )
        
        with open(output_path, 'w') as f:
            f.write(rendered)
        
        print(f"Report generated: {output_path}")

# Usage
if __name__ == "__main__":
    import sys
    
    client_code = sys.argv[1] if len(sys.argv) > 1 else None
    generator = ClientReportGenerator(client_code)
    generator.generate_report('compliance-report', 'output/report.html')
```

## Brand Asset Organization

### File Naming Conventions

```
# Asset Naming Standards
Format: [category]-[variant]-[size/format].[ext]

Examples:
├── logo-primary-horizontal.svg
├── logo-primary-vertical-300dpi.png
├── logo-secondary-monochrome.pdf
├── color-palette-primary.yaml
├── font-roboto-regular.woff2
├── template-executive-cover.html
├── icon-security-shield-24px.svg
└── pattern-background-subtle.png

# Client-Specific Assets
Format: [client-code]-[category]-[variant].[ext]

Examples:
├── ACME-logo-primary.svg
├── ACME-color-palette.yaml
├── BETA-template-cover.html
└── GAMMA-font-custom.woff2
```

### Asset Organization Schema

```yaml
# assets/asset-registry.yaml
registry:
  version: "1.0"
  last_updated: "2024-01-15"
  
  categories:
    logos:
      description: "Corporate logos and brand marks"
      formats: ["svg", "png", "pdf", "ico"]
      max_size: "5MB"
      required_variants: ["primary", "secondary", "monochrome"]
      
    fonts:
      description: "Typography assets"
      formats: ["woff2", "woff", "ttf", "otf"]
      max_size: "2MB"
      license_required: true
      
    colors:
      description: "Color palette definitions"
      formats: ["yaml", "json", "ase", "css"]
      validation: "hex_codes"
      
    templates:
      description: "Report and document templates"
      formats: ["html", "css", "scss", "pdf"]
      dependencies: ["fonts", "colors", "logos"]
      
    patterns:
      description: "Background patterns and textures"
      formats: ["svg", "png"]
      max_size: "1MB"
      tile_ready: true

  assets:
    - id: "logo-primary-horizontal"
      category: "logos"
      file: "logos/logo-primary-horizontal.svg"
      variant: "primary"
      format: "svg"
      size: "2.1MB"
      checksum: "sha256:abc123..."
      created: "2024-01-01"
      updated: "2024-01-15"
      usage: ["reports", "web", "presentations"]
      
    - id: "font-roboto-regular"
      category: "fonts"
      file: "fonts/roboto-regular.woff2"
      license: "Apache 2.0"
      weights: [400]
      styles: ["normal"]
      subset: "latin"
      size: "142KB"
```

### Asset Validation Framework

```python
#!/usr/bin/env python3
# scripts/validate-assets.py

import os
import yaml
import hashlib
from PIL import Image
from pathvalidate import validate_filename

class AssetValidator:
    def __init__(self, registry_path='assets/asset-registry.yaml'):
        self.registry = self.load_registry(registry_path)
        self.errors = []
        self.warnings = []
    
    def validate_all_assets(self):
        """Validate all assets in registry"""
        for asset in self.registry['assets']:
            self.validate_asset(asset)
        
        return len(self.errors) == 0
    
    def validate_asset(self, asset):
        """Validate individual asset"""
        file_path = f"assets/{asset['file']}"
        
        # Check file exists
        if not os.path.exists(file_path):
            self.errors.append(f"Asset file not found: {file_path}")
            return False
        
        # Validate filename
        try:
            validate_filename(asset['file'])
        except Exception as e:
            self.errors.append(f"Invalid filename: {asset['file']} - {e}")
        
        # Check file size
        file_size = os.path.getsize(file_path)
        max_size = self.get_max_size(asset['category'])
        if file_size > max_size:
            self.warnings.append(f"Asset {asset['id']} exceeds maximum size")
        
        # Validate checksum
        current_checksum = self.calculate_checksum(file_path)
        if 'checksum' in asset:
            if current_checksum != asset['checksum'].split(':')[1]:
                self.warnings.append(f"Checksum mismatch for {asset['id']}")
        
        # Category-specific validation
        if asset['category'] == 'logos':
            self.validate_logo(file_path, asset)
        elif asset['category'] == 'fonts':
            self.validate_font(file_path, asset)
    
    def validate_logo(self, file_path, asset):
        """Validate logo assets"""
        if asset['format'] in ['png', 'jpg']:
            try:
                with Image.open(file_path) as img:
                    # Check minimum resolution
                    if asset.get('min_resolution'):
                        min_res = int(asset['min_resolution'].replace('dpi', ''))
                        if img.info.get('dpi', (72, 72))[0] < min_res:
                            self.warnings.append(f"Logo {asset['id']} below minimum DPI")
                    
                    # Check dimensions
                    if img.width < 120:  # Minimum web size
                        self.warnings.append(f"Logo {asset['id']} below minimum width")
                        
            except Exception as e:
                self.errors.append(f"Cannot validate image {asset['id']}: {e}")
    
    def get_max_size(self, category):
        """Get maximum file size for category"""
        sizes = {
            'logos': 5 * 1024 * 1024,      # 5MB
            'fonts': 2 * 1024 * 1024,      # 2MB
            'patterns': 1 * 1024 * 1024,   # 1MB
        }
        return sizes.get(category, 10 * 1024 * 1024)  # Default 10MB
    
    def calculate_checksum(self, file_path):
        """Calculate SHA256 checksum"""
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                sha256_hash.update(chunk)
        return sha256_hash.hexdigest()

# Usage
if __name__ == "__main__":
    validator = AssetValidator()
    if validator.validate_all_assets():
        print("✓ All assets valid")
    else:
        print("✗ Asset validation failed")
        for error in validator.errors:
            print(f"ERROR: {error}")
        for warning in validator.warnings:
            print(f"WARNING: {warning}")
```

## Quality Assurance and Compliance

### Brand Compliance Checklist

```yaml
# validation/compliance-checklist.yaml
brand_compliance:
  visual_identity:
    - logo_usage_correct: "Logo used per brand guidelines"
    - color_accuracy: "Colors match approved palette"
    - typography_consistent: "Fonts match brand standards"
    - clear_space_maintained: "Adequate clear space around logos"
    - minimum_sizes_observed: "Logos meet minimum size requirements"
    
  content_standards:
    - terminology_consistent: "Brand terminology used consistently"
    - tone_appropriate: "Content tone matches brand voice"
    - messaging_aligned: "Key messages align with brand positioning"
    - legal_compliance: "Legal disclaimers and notices present"
    
  technical_quality:
    - image_resolution: "Images meet minimum resolution requirements"
    - color_profiles: "Correct color profiles (sRGB web, CMYK print)"
    - file_formats: "Appropriate file formats for use case"
    - accessibility: "WCAG 2.1 AA compliance"
    
  document_formatting:
    - layout_consistency: "Consistent layout across sections"
    - header_footer_correct: "Headers and footers properly formatted"
    - page_numbering: "Page numbering consistent and accurate"
    - table_formatting: "Tables follow brand styling guidelines"
```

### Automated Quality Assurance

```python
#!/usr/bin/env python3
# scripts/qa-brand-compliance.py

import yaml
from pathlib import Path
from colormath.color_objects import sRGBColor, HSVColor
from colormath.color_conversions import convert_color
from colormath.color_diff import delta_e_cie2000

class BrandComplianceChecker:
    def __init__(self, config_path='branding.yaml'):
        self.config = self.load_config(config_path)
        self.brand_colors = self.extract_brand_colors()
        self.compliance_results = {
            'passed': [],
            'failed': [],
            'warnings': []
        }
    
    def check_color_compliance(self, test_colors):
        """Check if colors match brand palette within tolerance"""
        tolerance = 5.0  # Delta E tolerance
        
        for test_color_hex in test_colors:
            test_color = sRGBColor.new_from_rgb_hex(test_color_hex)
            
            matches = []
            for brand_name, brand_hex in self.brand_colors.items():
                brand_color = sRGBColor.new_from_rgb_hex(brand_hex)
                delta_e = delta_e_cie2000(test_color, brand_color)
                
                if delta_e <= tolerance:
                    matches.append((brand_name, delta_e))
            
            if matches:
                best_match = min(matches, key=lambda x: x[1])
                self.compliance_results['passed'].append({
                    'test': 'color_compliance',
                    'value': test_color_hex,
                    'match': best_match[0],
                    'delta_e': best_match[1]
                })
            else:
                self.compliance_results['failed'].append({
                    'test': 'color_compliance',
                    'value': test_color_hex,
                    'issue': 'Color not in approved palette'
                })
    
    def check_typography_compliance(self, document_fonts):
        """Check if fonts match brand standards"""
        approved_fonts = [
            self.config['brand']['visual']['typography']['primary_font'],
            self.config['brand']['visual']['typography']['heading_font'],
            self.config['brand']['visual']['typography']['monospace_font']
        ]
        
        for font in document_fonts:
            if font in approved_fonts:
                self.compliance_results['passed'].append({
                    'test': 'typography_compliance',
                    'font': font,
                    'status': 'approved'
                })
            else:
                self.compliance_results['failed'].append({
                    'test': 'typography_compliance',
                    'font': font,
                    'issue': 'Font not in approved list'
                })
    
    def check_logo_usage(self, logo_instances):
        """Validate logo usage compliance"""
        for instance in logo_instances:
            # Check minimum size
            if instance['width'] < 120:  # pixels
                self.compliance_results['failed'].append({
                    'test': 'logo_minimum_size',
                    'location': instance['location'],
                    'width': instance['width'],
                    'issue': 'Below minimum size (120px)'
                })
            
            # Check clear space
            required_clear_space = instance['height'] * 0.5
            if instance['clear_space'] < required_clear_space:
                self.compliance_results['warnings'].append({
                    'test': 'logo_clear_space',
                    'location': instance['location'],
                    'clear_space': instance['clear_space'],
                    'required': required_clear_space,
                    'issue': 'Insufficient clear space'
                })
    
    def generate_compliance_report(self):
        """Generate compliance report"""
        total_tests = len(self.compliance_results['passed']) + \
                     len(self.compliance_results['failed']) + \
                     len(self.compliance_results['warnings'])
        
        passed_count = len(self.compliance_results['passed'])
        compliance_score = (passed_count / total_tests) * 100 if total_tests > 0 else 0
        
        report = {
            'summary': {
                'total_tests': total_tests,
                'passed': passed_count,
                'failed': len(self.compliance_results['failed']),
                'warnings': len(self.compliance_results['warnings']),
                'compliance_score': round(compliance_score, 1)
            },
            'results': self.compliance_results
        }
        
        return report
```

### Brand Guidelines Validation

```bash
#!/bin/bash
# scripts/validate-brand-guidelines.sh

echo "Brand Guidelines Compliance Validation"
echo "======================================"

# Color palette validation
echo "Checking color compliance..."
python scripts/extract-colors.py Report/Final-Report.html > /tmp/report-colors.txt
python scripts/qa-brand-compliance.py --test colors --input /tmp/report-colors.txt

# Typography validation  
echo "Checking typography compliance..."
grep -oP 'font-family:\s*[^;]+' Report/assets/css/*.css > /tmp/report-fonts.txt
python scripts/qa-brand-compliance.py --test typography --input /tmp/report-fonts.txt

# Logo usage validation
echo "Checking logo usage..."
python scripts/extract-logos.py Report/Final-Report.html > /tmp/logo-usage.json
python scripts/qa-brand-compliance.py --test logos --input /tmp/logo-usage.json

# Accessibility validation
echo "Checking accessibility compliance..."
axe-core --format json Report/Final-Report.html > /tmp/accessibility-results.json

# Generate compliance report
echo "Generating compliance report..."
python scripts/generate-compliance-report.py \
    --colors /tmp/report-colors.txt \
    --fonts /tmp/report-fonts.txt \
    --logos /tmp/logo-usage.json \
    --accessibility /tmp/accessibility-results.json \
    --output validation/compliance-report-$(date +%Y%m%d).json

echo "Validation complete. Check compliance report for results."
```

## Integration Workflows

### Report Generation Pipeline

```yaml
# .github/workflows/generate-branded-report.yml
name: Generate Branded Security Assessment Report

on:
  push:
    branches: [main]
    paths: ['Assessment/**', 'Report/**', 'Branding/**']
  workflow_dispatch:
    inputs:
      client_code:
        description: 'Client code for branded report'
        required: false
        type: string

jobs:
  validate-branding:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          sudo apt-get install wkhtmltopdf
      
      - name: Validate brand assets
        run: |
          python scripts/validate-assets.py
          python scripts/validate-branding.py branding.yaml
      
      - name: Check brand compliance
        run: |
          bash scripts/validate-brand-guidelines.sh
  
  generate-report:
    needs: validate-branding
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Activate client branding
        if: github.event.inputs.client_code
        run: |
          bash scripts/activate-client.sh ${{ github.event.inputs.client_code }}
      
      - name: Generate branded report
        run: |
          python scripts/generate-report.py \
            --template compliance-report \
            --output reports/Security-Assessment-Report-$(date +%Y%m%d).pdf \
            --format pdf
      
      - name: Quality assurance check
        run: |
          python scripts/qa-brand-compliance.py \
            --input reports/Security-Assessment-Report-*.pdf \
            --output validation/qa-results.json
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: branded-report
          path: |
            reports/*.pdf
            validation/qa-results.json
            validation/compliance-report-*.json
```

### Continuous Integration Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit (Brand validation pre-commit hook)

set -e

echo "Running brand compliance validation..."

# Check if branding files have been modified
if git diff --cached --name-only | grep -q "^Branding/"; then
    echo "Branding files modified. Running validation..."
    
    # Validate brand configuration
    python scripts/validate-branding.py branding.yaml
    if [ $? -ne 0 ]; then
        echo "❌ Brand configuration validation failed"
        exit 1
    fi
    
    # Validate brand assets
    python scripts/validate-assets.py
    if [ $? -ne 0 ]; then
        echo "❌ Brand asset validation failed"
        exit 1
    fi
    
    echo "✅ Brand validation passed"
fi

# Check report templates for compliance
if git diff --cached --name-only | grep -q "Report/templates"; then
    echo "Report templates modified. Checking brand compliance..."
    
    # Generate test report
    python scripts/generate-report.py \
        --template test \
        --output /tmp/test-report.html \
        --format html
    
    # Check brand compliance
    python scripts/qa-brand-compliance.py \
        --input /tmp/test-report.html \
        --threshold 90
    
    if [ $? -ne 0 ]; then
        echo "❌ Report template brand compliance check failed"
        exit 1
    fi
    
    echo "✅ Report template compliance check passed"
fi

exit 0
```

### Build and Deployment Integration

```python
#!/usr/bin/env python3
# scripts/build-pipeline-integration.py

import os
import sys
import json
import subprocess
from pathlib import Path

class BrandedBuildPipeline:
    def __init__(self, config_path='pipeline-config.yaml'):
        self.config = self.load_config(config_path)
        self.client_code = os.getenv('CLIENT_CODE')
        self.build_artifacts = []
    
    def prepare_branding(self):
        """Prepare branding configuration for build"""
        if self.client_code:
            print(f"Activating client branding: {self.client_code}")
            result = subprocess.run([
                'bash', 'scripts/activate-client.sh', self.client_code
            ], capture_output=True, text=True)
            
            if result.returncode != 0:
                print(f"Failed to activate client branding: {result.stderr}")
                sys.exit(1)
        
        # Validate branding configuration
        result = subprocess.run([
            'python', 'scripts/validate-branding.py', 'branding.yaml'
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            print(f"Brand validation failed: {result.stderr}")
            sys.exit(1)
    
    def build_reports(self):
        """Build all report variants"""
        report_types = self.config.get('report_types', ['executive', 'technical', 'compliance'])
        
        for report_type in report_types:
            print(f"Building {report_type} report...")
            
            output_name = f"Security-Assessment-{report_type.title()}"
            if self.client_code:
                output_name += f"-{self.client_code}"
            
            # Generate PDF
            subprocess.run([
                'python', 'scripts/generate-report.py',
                '--template', report_type,
                '--output', f'dist/{output_name}.pdf',
                '--format', 'pdf'
            ], check=True)
            
            # Generate HTML
            subprocess.run([
                'python', 'scripts/generate-report.py',
                '--template', report_type,
                '--output', f'dist/{output_name}.html',
                '--format', 'html'
            ], check=True)
            
            self.build_artifacts.extend([
                f'dist/{output_name}.pdf',
                f'dist/{output_name}.html'
            ])
    
    def quality_assurance(self):
        """Run QA checks on built reports"""
        for artifact in self.build_artifacts:
            if artifact.endswith('.pdf'):
                continue  # Skip PDF QA for now
                
            print(f"Running QA on {artifact}...")
            result = subprocess.run([
                'python', 'scripts/qa-brand-compliance.py',
                '--input', artifact,
                '--threshold', '85',
                '--output', f'qa/qa-{Path(artifact).stem}.json'
            ], capture_output=True, text=True)
            
            if result.returncode != 0:
                print(f"QA failed for {artifact}: {result.stderr}")
                sys.exit(1)
    
    def package_deliverables(self):
        """Package final deliverables"""
        package_name = "security-assessment-reports"
        if self.client_code:
            package_name += f"-{self.client_code}"
        
        # Create package directory
        package_dir = f'packages/{package_name}'
        os.makedirs(package_dir, exist_ok=True)
        
        # Copy reports
        for artifact in self.build_artifacts:
            subprocess.run([
                'cp', artifact, f'{package_dir}/'
            ], check=True)
        
        # Copy supporting documents
        supporting_docs = [
            'Assessment/Executive-Summary.md',
            'Assessment/Methodology.md',
            'Artifacts/Risk-Register.csv'
        ]
        
        for doc in supporting_docs:
            if os.path.exists(doc):
                subprocess.run([
                    'cp', doc, f'{package_dir}/'
                ], check=True)
        
        # Create package manifest
        manifest = {
            'package_name': package_name,
            'client_code': self.client_code,
            'build_date': subprocess.getoutput('date -u +"%Y-%m-%dT%H:%M:%SZ"'),
            'artifacts': [os.path.basename(f) for f in self.build_artifacts],
            'checksum': self.calculate_package_checksum(package_dir)
        }
        
        with open(f'{package_dir}/manifest.json', 'w') as f:
            json.dump(manifest, f, indent=2)
        
        print(f"Package created: {package_dir}")

# Usage
if __name__ == "__main__":
    pipeline = BrandedBuildPipeline()
    pipeline.prepare_branding()
    pipeline.build_reports()
    pipeline.quality_assurance()
    pipeline.package_deliverables()
    print("Build pipeline completed successfully")
```

## Version Control and Change Management

### Brand Asset Versioning

```yaml
# versioning/brand-version-control.yaml
versioning:
  strategy: "semantic"  # semantic, date-based, incremental
  current_version: "2.1.0"
  
  changelog:
    "2.1.0":
      date: "2024-01-15"
      changes:
        - "Updated primary color palette"
        - "Added new logo variants"
        - "Improved accessibility compliance"
      assets_changed:
        - "colors/primary-palette.yaml"
        - "logos/logo-primary-horizontal.svg"
      breaking_changes: false
      
    "2.0.0":
      date: "2023-12-01"
      changes:
        - "Complete brand refresh"
        - "New typography system"
        - "Updated report templates"
      breaking_changes: true
      migration_guide: "docs/migration-v1-to-v2.md"
  
  compatibility:
    "2.1.0": ["2.0.0", "1.9.x"]
    "2.0.0": ["1.8.x", "1.9.x"]
    
  deprecation:
    schedule:
      "1.x": "2024-06-01"  # End of support
    warnings:
      - version: "1.8.x"
        message: "Version 1.x will be deprecated on 2024-06-01"
        migration_path: "docs/migration-v1-to-v2.md"
```

### Change Management Process

```bash
#!/bin/bash
# scripts/brand-change-management.sh

CHANGE_TYPE=$1  # major, minor, patch
CHANGE_DESC="$2"

if [ -z "$CHANGE_TYPE" ] || [ -z "$CHANGE_DESC" ]; then
    echo "Usage: $0 <major|minor|patch> 'change description'"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(grep "current_version:" versioning/brand-version-control.yaml | cut -d'"' -f2)
echo "Current version: $CURRENT_VERSION"

# Calculate new version
case $CHANGE_TYPE in
    "major")
        NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print ($1+1)".0.0"}')
        ;;
    "minor")
        NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."($2+1)".0"}')
        ;;
    "patch")
        NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2"."($3+1)}')
        ;;
    *)
        echo "Invalid change type. Use major, minor, or patch."
        exit 1
        ;;
esac

echo "New version: $NEW_VERSION"

# Create version branch
git checkout -b "brand-update-v$NEW_VERSION"

# Update version in configuration
sed -i "s/current_version: \"$CURRENT_VERSION\"/current_version: \"$NEW_VERSION\"/" \
    versioning/brand-version-control.yaml

# Add changelog entry
python scripts/update-changelog.py \
    --version "$NEW_VERSION" \
    --description "$CHANGE_DESC" \
    --type "$CHANGE_TYPE"

# Run validation tests
echo "Running brand validation tests..."
python scripts/validate-branding.py branding.yaml
python scripts/validate-assets.py

if [ $? -eq 0 ]; then
    echo "✅ Validation passed"
    
    # Commit changes
    git add .
    git commit -m "brand: update to version $NEW_VERSION

$CHANGE_DESC

Type: $CHANGE_TYPE"
    
    # Push branch and create PR
    git push -u origin "brand-update-v$NEW_VERSION"
    gh pr create \
        --title "Brand Update v$NEW_VERSION" \
        --body "## Changes

$CHANGE_DESC

**Change Type:** $CHANGE_TYPE
**Version:** $NEW_VERSION

## Validation

- [x] Brand configuration validated
- [x] Asset validation passed
- [x] Compatibility check completed

## Review Checklist

- [ ] Visual identity guidelines reviewed
- [ ] Asset quality verified
- [ ] Client impact assessment completed
- [ ] Documentation updated" \
        --reviewer "brand-team" \
        --label "brand-update"
    
    echo "✅ Brand update PR created successfully"
else
    echo "❌ Validation failed. Please fix issues before proceeding."
    exit 1
fi
```

### Asset Migration and Backward Compatibility

```python
#!/usr/bin/env python3
# scripts/migrate-brand-assets.py

import yaml
import json
import shutil
from pathlib import Path
from typing import Dict, List

class BrandAssetMigrator:
    def __init__(self):
        self.migrations = self.load_migrations()
        self.backup_dir = Path('backups/brand-migration')
        self.backup_dir.mkdir(parents=True, exist_ok=True)
    
    def load_migrations(self) -> Dict:
        """Load migration configurations"""
        with open('versioning/migrations.yaml', 'r') as f:
            return yaml.safe_load(f)
    
    def migrate_to_version(self, target_version: str):
        """Migrate assets to target version"""
        current_version = self.get_current_version()
        migration_path = self.find_migration_path(current_version, target_version)
        
        if not migration_path:
            raise ValueError(f"No migration path from {current_version} to {target_version}")
        
        # Create backup
        self.create_backup(current_version)
        
        # Execute migrations in order
        for migration in migration_path:
            print(f"Executing migration: {migration['name']}")
            self.execute_migration(migration)
        
        # Update version
        self.update_version(target_version)
        
        # Validate migration
        if self.validate_migration(target_version):
            print(f"✅ Migration to {target_version} completed successfully")
        else:
            print(f"❌ Migration validation failed. Rolling back...")
            self.rollback_migration(current_version)
    
    def execute_migration(self, migration: Dict):
        """Execute individual migration"""
        for action in migration['actions']:
            if action['type'] == 'move_asset':
                self.move_asset(action['from'], action['to'])
            elif action['type'] == 'update_config':
                self.update_config(action['file'], action['changes'])
            elif action['type'] == 'convert_format':
                self.convert_format(action['asset'], action['from_format'], action['to_format'])
            elif action['type'] == 'update_references':
                self.update_references(action['old_path'], action['new_path'])
    
    def move_asset(self, from_path: str, to_path: str):
        """Move asset to new location"""
        source = Path(f'assets/{from_path}')
        target = Path(f'assets/{to_path}')
        
        if source.exists():
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(source), str(target))
            print(f"  Moved: {from_path} → {to_path}")
    
    def update_config(self, file_path: str, changes: Dict):
        """Update configuration file"""
        config_path = Path(file_path)
        
        if config_path.suffix == '.yaml':
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)
            
            # Apply changes
            for key_path, value in changes.items():
                self.set_nested_value(config, key_path.split('.'), value)
            
            with open(config_path, 'w') as f:
                yaml.dump(config, f, default_flow_style=False)
        
        print(f"  Updated config: {file_path}")
    
    def validate_migration(self, version: str) -> bool:
        """Validate migration success"""
        import subprocess
        
        # Run brand validation
        result = subprocess.run([
            'python', 'scripts/validate-branding.py', 'branding.yaml'
        ], capture_output=True)
        
        if result.returncode != 0:
            return False
        
        # Run asset validation
        result = subprocess.run([
            'python', 'scripts/validate-assets.py'
        ], capture_output=True)
        
        return result.returncode == 0
    
    def create_backup(self, version: str):
        """Create backup of current assets"""
        backup_path = self.backup_dir / f'backup-{version}'
        backup_path.mkdir(exist_ok=True)
        
        # Backup assets
        if Path('assets').exists():
            shutil.copytree('assets', backup_path / 'assets', dirs_exist_ok=True)
        
        # Backup configurations
        for config_file in ['branding.yaml', 'versioning/brand-version-control.yaml']:
            if Path(config_file).exists():
                shutil.copy2(config_file, backup_path / Path(config_file).name)
        
        print(f"  Backup created: {backup_path}")

# Migration configuration example
migrations_yaml = """
migrations:
  - name: "v1.9_to_v2.0"
    from_version: "1.9.x"
    to_version: "2.0.0"
    breaking_changes: true
    actions:
      - type: "move_asset"
        from: "logo.png"
        to: "logos/logo-primary.png"
      - type: "update_config"
        file: "branding.yaml"
        changes:
          "brand.visual.logo.primary": "assets/logos/logo-primary.png"
      - type: "convert_format"
        asset: "logos/logo-primary.png"
        from_format: "png"
        to_format: "svg"
  
  - name: "v2.0_to_v2.1"
    from_version: "2.0.0"
    to_version: "2.1.0"
    breaking_changes: false
    actions:
      - type: "update_config"
        file: "branding.yaml"
        changes:
          "brand.visual.colors.primary": "#1B365D"
"""
```

## Accessibility and Responsive Design

### Accessibility Standards

```yaml
# accessibility/wcag-compliance.yaml
accessibility:
  standards:
    target: "WCAG 2.1 AA"
    additional: ["Section 508", "ADA"]
    
  color_contrast:
    normal_text:
      minimum: 4.5
      enhanced: 7.0
    large_text:
      minimum: 3.0
      enhanced: 4.5
    
  color_requirements:
    color_blind_safe: true
    high_contrast_mode: true
    forced_colors_mode: true
    
  typography:
    minimum_font_size: "14px"
    line_height: 1.5
    paragraph_spacing: "1em"
    
  interactive_elements:
    focus_indicators: required
    keyboard_navigation: full
    touch_targets: "44px minimum"
    
  media:
    alt_text: required
    captions: "video content"
    audio_descriptions: "complex visuals"
```

### Responsive Design Framework

```scss
// assets/scss/_responsive-branding.scss

// Breakpoint system
$breakpoints: (
  'mobile': 320px,
  'tablet': 768px,
  'desktop': 1024px,
  'large': 1440px,
  'xlarge': 1920px
);

@mixin respond-to($breakpoint) {
  @if map-has-key($breakpoints, $breakpoint) {
    @media (min-width: map-get($breakpoints, $breakpoint)) {
      @content;
    }
  }
}

// Responsive logo sizing
.brand-logo {
  max-width: 100%;
  height: auto;
  
  // Mobile: smaller logo
  @include respond-to('mobile') {
    max-height: 32px;
  }
  
  // Tablet: medium logo
  @include respond-to('tablet') {
    max-height: 48px;
  }
  
  // Desktop: full size logo
  @include respond-to('desktop') {
    max-height: 64px;
  }
}

// Responsive typography scale
.report-title {
  font-size: clamp(1.5rem, 4vw, 2.5rem);
  line-height: 1.2;
  
  @include respond-to('mobile') {
    font-size: 1.5rem;
  }
  
  @include respond-to('tablet') {
    font-size: 2rem;
  }
  
  @include respond-to('desktop') {
    font-size: 2.5rem;
  }
}

// Responsive color adjustments
@media (prefers-color-scheme: dark) {
  :root {
    --color-primary: #{lighten($color-primary, 20%)};
    --color-secondary: #{lighten($color-secondary, 15%)};
    --color-text-primary: #{$color-neutral-light};
    --color-background: #{$color-neutral-dark};
  }
}

// High contrast mode support
@media (prefers-contrast: high) {
  :root {
    --color-primary: #000000;
    --color-secondary: #333333;
    --color-accent: #0066CC;
  }
  
  .brand-logo {
    filter: contrast(1.5);
  }
}

// Reduced motion support
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

// Print styles
@media print {
  .brand-logo {
    max-height: 1in;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }
  
  .report-title {
    color: black !important;
    font-size: 18pt;
  }
  
  // Ensure colors print correctly
  * {
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }
}
```

### Accessibility Validation

```python
#!/usr/bin/env python3
# scripts/validate-accessibility.py

import json
import subprocess
from pathlib import Path
from colormath.color_objects import sRGBColor
from colormath.color_diff import delta_e_cie2000

class AccessibilityValidator:
    def __init__(self):
        self.wcag_thresholds = {
            'normal_text': 4.5,
            'large_text': 3.0,
            'enhanced_normal': 7.0,
            'enhanced_large': 4.5
        }
    
    def validate_color_contrast(self, foreground_hex: str, background_hex: str) -> Dict:
        """Validate color contrast ratios"""
        fg_color = sRGBColor.new_from_rgb_hex(foreground_hex)
        bg_color = sRGBColor.new_from_rgb_hex(background_hex)
        
        # Calculate luminance
        fg_lum = self.calculate_luminance(fg_color)
        bg_lum = self.calculate_luminance(bg_color)
        
        # Calculate contrast ratio
        if fg_lum > bg_lum:
            contrast_ratio = (fg_lum + 0.05) / (bg_lum + 0.05)
        else:
            contrast_ratio = (bg_lum + 0.05) / (fg_lum + 0.05)
        
        return {
            'contrast_ratio': round(contrast_ratio, 2),
            'wcag_aa_normal': contrast_ratio >= self.wcag_thresholds['normal_text'],
            'wcag_aa_large': contrast_ratio >= self.wcag_thresholds['large_text'],
            'wcag_aaa_normal': contrast_ratio >= self.wcag_thresholds['enhanced_normal'],
            'wcag_aaa_large': contrast_ratio >= self.wcag_thresholds['enhanced_large']
        }
    
    def validate_document_accessibility(self, html_file: str) -> Dict:
        """Run automated accessibility testing"""
        # Use axe-core for automated testing
        result = subprocess.run([
            'axe', '--format', 'json', html_file
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            return json.loads(result.stdout)
        else:
            return {'error': result.stderr}
    
    def generate_accessibility_report(self, html_files: List[str]) -> Dict:
        """Generate comprehensive accessibility report"""
        report = {
            'summary': {
                'total_files': len(html_files),
                'total_violations': 0,
                'total_warnings': 0,
                'compliance_level': 'Unknown'
            },
            'files': {}
        }
        
        for html_file in html_files:
            file_report = self.validate_document_accessibility(html_file)
            report['files'][html_file] = file_report
            
            if 'violations' in file_report:
                report['summary']['total_violations'] += len(file_report['violations'])
            
        # Determine compliance level
        if report['summary']['total_violations'] == 0:
            report['summary']['compliance_level'] = 'WCAG 2.1 AA'
        else:
            report['summary']['compliance_level'] = 'Non-compliant'
        
        return report

# Usage example
if __name__ == "__main__":
    validator = AccessibilityValidator()
    
    # Test color combinations from brand palette
    color_tests = [
        ('#1B365D', '#FFFFFF'),  # Primary on white
        ('#4A90A4', '#FFFFFF'),  # Secondary on white  
        ('#718096', '#FFFFFF'),  # Gray on white
    ]
    
    print("Color Contrast Validation:")
    print("=" * 40)
    
    for fg, bg in color_tests:
        result = validator.validate_color_contrast(fg, bg)
        print(f"Foreground: {fg}, Background: {bg}")
        print(f"  Contrast Ratio: {result['contrast_ratio']}:1")
        print(f"  WCAG AA (Normal): {'✓' if result['wcag_aa_normal'] else '✗'}")
        print(f"  WCAG AA (Large): {'✓' if result['wcag_aa_large'] else '✗'}")
        print(f"  WCAG AAA (Normal): {'✓' if result['wcag_aaa_normal'] else '✗'}")
        print()
```

## Brand Enforcement and Validation

### Automated Brand Validation Tools

```yaml
# validation/brand-enforcement-rules.yaml
enforcement:
  logo_usage:
    rules:
      - name: "minimum_size_check"
        description: "Logo must meet minimum size requirements"
        condition: "width >= 120px AND height >= 40px"
        severity: "error"
        
      - name: "clear_space_validation"
        description: "Logo must have adequate clear space"
        condition: "clear_space >= (logo_height * 0.5)"
        severity: "warning"
        
      - name: "approved_formats_only"
        description: "Only approved logo formats allowed"
        condition: "format IN ['svg', 'png', 'pdf']"
        severity: "error"
  
  color_usage:
    rules:
      - name: "approved_colors_only"
        description: "Only brand-approved colors allowed"
        condition: "color IN brand_palette"
        severity: "error"
        tolerance: 5.0  # Delta E tolerance
        
      - name: "contrast_compliance"
        description: "Color combinations must meet WCAG standards"
        condition: "contrast_ratio >= 4.5"
        severity: "error"
  
  typography:
    rules:
      - name: "approved_fonts_only"
        description: "Only brand-approved fonts allowed"
        condition: "font_family IN approved_fonts"
        severity: "error"
        
      - name: "minimum_font_size"
        description: "Text must meet minimum size requirements"
        condition: "font_size >= 14px"
        severity: "warning"
  
  templates:
    rules:
      - name: "required_sections"
        description: "Reports must include required sections"
        condition: "ALL required_sections PRESENT"
        severity: "error"
        
      - name: "branding_elements"
        description: "All branding elements must be present"
        condition: "logo AND header AND footer PRESENT"
        severity: "error"
```

### Brand Compliance Dashboard

```python
#!/usr/bin/env python3
# scripts/brand-compliance-dashboard.py

import json
import yaml
from datetime import datetime, timedelta
from typing import Dict, List
import matplotlib.pyplot as plt
import seaborn as sns

class BrandComplianceDashboard:
    def __init__(self):
        self.compliance_data = self.load_compliance_history()
        self.enforcement_rules = self.load_enforcement_rules()
    
    def generate_compliance_metrics(self) -> Dict:
        """Generate brand compliance metrics"""
        recent_reports = self.get_recent_reports(days=30)
        
        metrics = {
            'overall_compliance_score': self.calculate_overall_score(recent_reports),
            'compliance_trend': self.calculate_trend(recent_reports),
            'violation_breakdown': self.analyze_violations(recent_reports),
            'improvement_areas': self.identify_improvement_areas(recent_reports),
            'client_compliance_scores': self.calculate_client_scores(recent_reports)
        }
        
        return metrics
    
    def calculate_overall_score(self, reports: List[Dict]) -> float:
        """Calculate overall compliance score"""
        if not reports:
            return 0.0
        
        total_tests = sum(len(r.get('tests', [])) for r in reports)
        total_passed = sum(len([t for t in r.get('tests', []) if t['status'] == 'passed']) for r in reports)
        
        return (total_passed / total_tests) * 100 if total_tests > 0 else 0.0
    
    def generate_dashboard_html(self) -> str:
        """Generate HTML dashboard"""
        metrics = self.generate_compliance_metrics()
        
        html_template = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Brand Compliance Dashboard</title>
            <style>
                body {{ font-family: 'Roboto', sans-serif; margin: 0; padding: 20px; background: #f8f9fa; }}
                .dashboard {{ max-width: 1200px; margin: 0 auto; }}
                .metric-card {{ background: white; padding: 20px; margin: 10px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }}
                .score {{ font-size: 2.5em; font-weight: bold; color: {score_color}; }}
                .trend {{ color: {trend_color}; }}
                .violation-item {{ padding: 10px; border-left: 4px solid {violation_color}; margin: 5px 0; }}
            </style>
        </head>
        <body>
            <div class="dashboard">
                <h1>Brand Compliance Dashboard</h1>
                
                <div class="metric-card">
                    <h2>Overall Compliance Score</h2>
                    <div class="score">{overall_score:.1f}%</div>
                    <div class="trend">Trend: {trend}</div>
                </div>
                
                <div class="metric-card">
                    <h2>Recent Violations</h2>
                    {violation_list}
                </div>
                
                <div class="metric-card">
                    <h2>Client Compliance Scores</h2>
                    {client_scores}
                </div>
                
                <div class="metric-card">
                    <h2>Improvement Recommendations</h2>
                    {recommendations}
                </div>
            </div>
        </body>
        </html>
        """.format(
            overall_score=metrics['overall_compliance_score'],
            trend=metrics['compliance_trend'],
            score_color='#28a745' if metrics['overall_compliance_score'] >= 90 else '#ffc107' if metrics['overall_compliance_score'] >= 70 else '#dc3545',
            trend_color='#28a745' if 'improving' in metrics['compliance_trend'].lower() else '#dc3545',
            violation_color='#dc3545',
            violation_list=self.format_violations_html(metrics['violation_breakdown']),
            client_scores=self.format_client_scores_html(metrics['client_compliance_scores']),
            recommendations=self.format_recommendations_html(metrics['improvement_areas'])
        )
        
        return html_template
    
    def create_compliance_charts(self):
        """Create compliance visualization charts"""
        metrics = self.generate_compliance_metrics()
        
        # Set style
        plt.style.use('seaborn-v0_8')
        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(15, 10))
        
        # Overall compliance trend
        dates = [datetime.now() - timedelta(days=x) for x in range(30, 0, -1)]
        scores = [self.get_daily_compliance_score(date) for date in dates]
        
        ax1.plot(dates, scores, marker='o', linewidth=2, markersize=4)
        ax1.set_title('Compliance Score Trend (30 Days)')
        ax1.set_ylabel('Compliance Score (%)')
        ax1.grid(True, alpha=0.3)
        
        # Violation breakdown
        violations = metrics['violation_breakdown']
        if violations:
            ax2.pie(violations.values(), labels=violations.keys(), autopct='%1.1f%%')
            ax2.set_title('Violation Types Distribution')
        
        # Client compliance scores
        client_scores = metrics['client_compliance_scores']
        if client_scores:
            clients = list(client_scores.keys())
            scores = list(client_scores.values())
            
            bars = ax3.bar(clients, scores)
            ax3.set_title('Client Compliance Scores')
            ax3.set_ylabel('Compliance Score (%)')
            ax3.tick_params(axis='x', rotation=45)
            
            # Color bars based on score
            for i, (bar, score) in enumerate(zip(bars, scores)):
                if score >= 90:
                    bar.set_color('#28a745')
                elif score >= 70:
                    bar.set_color('#ffc107')
                else:
                    bar.set_color('#dc3545')
        
        # Compliance by category
        categories = ['Logo Usage', 'Color Compliance', 'Typography', 'Templates']
        category_scores = [self.get_category_score(cat) for cat in categories]
        
        ax4.barh(categories, category_scores)
        ax4.set_title('Compliance by Category')
        ax4.set_xlabel('Compliance Score (%)')
        
        plt.tight_layout()
        plt.savefig('validation/compliance-dashboard.png', dpi=300, bbox_inches='tight')
        plt.close()

# CLI tool for brand enforcement
if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Brand Compliance Dashboard')
    parser.add_argument('--generate-dashboard', action='store_true', help='Generate HTML dashboard')
    parser.add_argument('--generate-charts', action='store_true', help='Generate compliance charts')
    parser.add_argument('--output-dir', default='validation', help='Output directory')
    
    args = parser.parse_args()
    
    dashboard = BrandComplianceDashboard()
    
    if args.generate_dashboard:
        html_content = dashboard.generate_dashboard_html()
        with open(f'{args.output_dir}/compliance-dashboard.html', 'w') as f:
            f.write(html_content)
        print(f"Dashboard generated: {args.output_dir}/compliance-dashboard.html")
    
    if args.generate_charts:
        dashboard.create_compliance_charts()
        print(f"Charts generated: {args.output_dir}/compliance-dashboard.png")
```

## Troubleshooting

### Common Brand Implementation Issues

| Issue | Symptoms | Root Cause | Solution |
|-------|----------|------------|----------|
| **Logo not displaying** | Broken image links in reports | Incorrect file path or missing asset | Verify logo path in `branding.yaml` and ensure file exists |
| **Colors not matching** | Brand colors appear different | Color profile mismatch | Ensure sRGB color space for digital, CMYK for print |
| **Fonts not loading** | Fallback fonts displayed | Font files missing or incorrect format | Check font file availability and web font formats |
| **Template not applying** | Default styling shown | Template selection or compilation issue | Verify template configuration and CSS compilation |
| **Client branding conflicts** | Mixed branding elements | Client configuration merge issues | Check client configuration merge logic |

### Diagnostic Commands

```bash
#!/bin/bash
# scripts/diagnose-branding.sh

echo "Brand Configuration Diagnostics"
echo "==============================="

# Check main configuration
echo "1. Validating main branding configuration..."
if python scripts/validate-branding.py branding.yaml; then
    echo "   ✓ Main configuration valid"
else
    echo "   ✗ Main configuration has errors"
fi

# Check asset availability
echo "2. Checking asset availability..."
LOGO_PATH=$(grep -A 5 "logo:" branding.yaml | grep "primary:" | cut -d'"' -f2)
if [ -f "$LOGO_PATH" ]; then
    echo "   ✓ Primary logo found: $LOGO_PATH"
else
    echo "   ✗ Primary logo missing: $LOGO_PATH"
fi

# Check font availability
echo "3. Checking font availability..."
FONT_DIR="assets/fonts/"
if [ -d "$FONT_DIR" ]; then
    FONT_COUNT=$(find "$FONT_DIR" -name "*.woff2" -o -name "*.woff" | wc -l)
    echo "   ✓ Found $FONT_COUNT font files in $FONT_DIR"
else
    echo "   ✗ Font directory not found: $FONT_DIR"
fi

# Check color definitions
echo "4. Validating color definitions..."
python -c "
import yaml
with open('branding.yaml', 'r') as f:
    config = yaml.safe_load(f)
colors = config['brand']['visual']['colors']
for name, hex_code in colors.items():
    if not hex_code.startswith('#') or len(hex_code) != 7:
        print(f'   ✗ Invalid color format: {name} = {hex_code}')
    else:
        print(f'   ✓ Valid color: {name} = {hex_code}')
"

# Check template compilation
echo "5. Testing template compilation..."
if python scripts/generate-report.py --template test --output /tmp/test-brand.html --format html > /dev/null 2>&1; then
    echo "   ✓ Template compilation successful"
else
    echo "   ✗ Template compilation failed"
fi

# Check client configurations
echo "6. Validating client configurations..."
if [ -d "clients/active" ]; then
    for CLIENT_DIR in clients/active/*/; do
        if [ -d "$CLIENT_DIR" ]; then
            CLIENT_NAME=$(basename "$CLIENT_DIR")
            if [ -f "${CLIENT_DIR}branding.yaml" ]; then
                echo "   ✓ Client configuration found: $CLIENT_NAME"
            else
                echo "   ✗ Client configuration missing: $CLIENT_NAME"
            fi
        fi
    done
else
    echo "   ! No client configurations directory found"
fi

echo
echo "Diagnostics complete. Check any ✗ items above for issues to resolve."
```

### Brand Asset Recovery

```bash
#!/bin/bash
# scripts/recover-brand-assets.sh

BACKUP_DIR="backups/brand-migration"
RECOVERY_DATE=${1:-$(date +%Y%m%d)}

echo "Brand Asset Recovery Utility"
echo "============================"
echo "Recovery date: $RECOVERY_DATE"

# Find available backups
echo "Available backups:"
if [ -d "$BACKUP_DIR" ]; then
    ls -la "$BACKUP_DIR" | grep "^d" | grep "backup-"
else
    echo "No backup directory found at $BACKUP_DIR"
    exit 1
fi

read -p "Enter backup version to restore (e.g., backup-2.0.0): " BACKUP_VERSION

BACKUP_PATH="$BACKUP_DIR/$BACKUP_VERSION"

if [ ! -d "$BACKUP_PATH" ]; then
    echo "Backup not found: $BACKUP_PATH"
    exit 1
fi

# Create recovery backup of current state
RECOVERY_BACKUP="$BACKUP_DIR/pre-recovery-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RECOVERY_BACKUP"

echo "Creating recovery backup at $RECOVERY_BACKUP..."
cp -r assets/ "$RECOVERY_BACKUP/" 2>/dev/null || true
cp branding.yaml "$RECOVERY_BACKUP/" 2>/dev/null || true

# Restore from backup
echo "Restoring from backup: $BACKUP_VERSION..."

if [ -d "$BACKUP_PATH/assets" ]; then
    echo "Restoring assets..."
    rm -rf assets/
    cp -r "$BACKUP_PATH/assets" ./
fi

if [ -f "$BACKUP_PATH/branding.yaml" ]; then
    echo "Restoring branding configuration..."
    cp "$BACKUP_PATH/branding.yaml" ./
fi

# Validate restored configuration
echo "Validating restored configuration..."
if python scripts/validate-branding.py branding.yaml; then
    echo "✓ Brand assets successfully recovered"
    echo "✓ Recovery backup created at: $RECOVERY_BACKUP"
else
    echo "✗ Validation failed. Rolling back..."
    
    # Rollback recovery
    if [ -d "$RECOVERY_BACKUP/assets" ]; then
        rm -rf assets/
        cp -r "$RECOVERY_BACKUP/assets" ./
    fi
    
    if [ -f "$RECOVERY_BACKUP/branding.yaml" ]; then
        cp "$RECOVERY_BACKUP/branding.yaml" ./
    fi
    
    echo "Recovery rolled back. Original state restored."
    exit 1
fi

echo "Brand asset recovery completed successfully."
```

---

This comprehensive guide transforms the basic branding documentation into an enterprise-grade corporate identity management system that supports professional security assessment report production at scale. The framework provides complete lifecycle management of brand assets, multi-client support, automated quality assurance, and seamless integration with report generation workflows.
