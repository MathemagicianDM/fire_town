# Template Import Guide

This directory contains YAML template files for the character description system. These files provide the structure and examples for creating physical and clothing descriptions.

## Files

### `physical_templates.yaml`
Contains templates for physical character traits including:
- **Hair** - Various hair styles and colors
- **Facial Hair** - Beards, mustaches with cultural elements
- **Eyes** - Eye descriptions that reflect personality/role
- **Build** - Body types appropriate for different professions
- **Hands** - Hand descriptions showing work/skill
- **Voice** - Speaking patterns and tones
- **Movement** - How characters carry themselves
- **Scars** - Profession-specific marks and wounds
- **Ancestry-Specific** - Scales, feathers, fur, horns, etc.

### `clothing_templates.yaml`
Contains templates for clothing and accessories including:
- **Professional Attire** - Role-specific work clothing
- **Cultural Clothing** - Ancestry-appropriate garments
- **Accessories** - Jewelry, tools, personal items
- **Footwear** - Profession and culture appropriate shoes/boots
- **Condition** - How well-maintained the clothing appears

## Template Structure

Each template follows this format:

```yaml
- template: "Description with {variable} substitutions"
  ancestry_groups: ["group1", "group2"]  # Optional
  roles: ["role1", "role2"]              # Optional  
  tags: ["tag1", "tag2"]                 # Required
```

## Available Variables

Use these in your template strings:
- `{name}` - Character's first name
- `{surname}` - Character's last name
- `{ancestry}` - Character's ancestry
- `{age}` - Age description (young, adult, elderly, etc.)
- `{pronoun_subject}` - he/she/they
- `{pronoun_object}` - him/her/them
- `{pronoun_possessive}` - his/her/their

## Ancestry Groups

Target specific character types:
- `all` - Universal (applies to everyone)
- `has_hair` - Ancestries with hair
- `has_beard` - Ancestries that can grow beards
- `feathered` - Bird-like ancestries
- `scaled` - Dragon/lizard-like ancestries
- `furred` - Mammalian ancestries
- `humanoid` - Human-like ancestries
- `bestial` - Animal-like ancestries
- `elemental` - Elemental ancestries

## Tags

### Physical Tags
Prevent conflicting traits:
- `hair`, `facial_hair`, `eyes`, `build`, `hands`
- `voice`, `movement`, `ears`, `scars`
- `plumage`, `beak`, `tusks`, `scales`, `fur`
- `tail`, `wings`, `horns`

### Clothing Tags
Prevent clothing conflicts:
- `head`, `torso`, `arms`, `hands_clothing`
- `waist`, `legs`, `feet`
- `jewelry`, `accessories`

## Usage Tips

1. **Be Specific** - Target appropriate ancestry groups and roles
2. **Avoid Conflicts** - Use proper tags to prevent contradictions
3. **Cultural Elements** - Include ancestry-specific details (like dwarf beard jewelry)
4. **Professional Relevance** - Match descriptions to character roles
5. **Variable Usage** - Use {variables} for dynamic, personalized content

## Example Template

```yaml
- template: "sports a magnificent braided beard decorated with traditional {ancestry} metal rings"
  ancestry_groups: ["has_beard"]
  roles: ["owner", "journeyman"] 
  tags: ["facial_hair", "jewelry"]
```

This template:
- Only applies to bearded ancestries
- Only appears on owners/journeymen (skilled professionals)
- Prevents conflicts with other facial hair or jewelry
- Uses {ancestry} variable for cultural specificity

## Adding Your Templates

1. Follow the existing format
2. Add appropriate ancestry_groups and roles
3. Use required tags to prevent conflicts
4. Test with your character generation system
5. Consider cultural elements from your world

## Import Process

Once you've filled in the templates:
1. Use the Template Manager in the app
2. Copy/paste your YAML content
3. Validate the templates
4. Import to make them available for generation

The system will use these templates to create unique, appropriate descriptions for every character based on their ancestry, role, and other traits.