"""Run with Blender 4.3+: blender -b -t 2 -P tools/build_station_assets.py.
Original mesh source. Poly Haven CC0 surface maps are bundled in assets/textures.
Blender axes: X width, Y length, Z up; GLB export converts to Godot Y up.
"""
import bpy, math, json
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/models"
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

def material(name, color, metal=0, rough=.8, texture=False):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    p = m.node_tree.nodes.get("Principled BSDF")
    p.inputs["Base Color"].default_value = (*color, 1)
    p.inputs["Metallic"].default_value = metal
    p.inputs["Roughness"].default_value = rough
    if texture:
        for suffix, socket in [("albedo", "Base Color"), ("roughness", "Roughness"), ("normal", "Normal")]:
            t=m.node_tree.nodes.new("ShaderNodeTexImage")
            t.image=bpy.data.images.load(str(ROOT / f"assets/textures/rust_{suffix}.jpg"),check_existing=True)
            if suffix != "albedo":t.image.colorspace_settings.name="Non-Color"
            output=t.outputs["Color"]
            if suffix=="normal":
                n=m.node_tree.nodes.new("ShaderNodeNormalMap")
                n.inputs["Strength"].default_value=.55
                m.node_tree.links.new(output,n.inputs["Color"]); output=n.outputs["Normal"]
            m.node_tree.links.new(output,p.inputs[socket])
    return m

rust=material("Oxidised steel - Poly Haven",(.34,.16,.08),.25,.9,True)
paint=material("Faded petrol blue enamel",(.105,.24,.23),.35,.66)
cream=material("Aged ivory enamel",(.64,.57,.40),.12,.7)
rubber=material("Dry rubber",(.025,.029,.027),0,.98)
chrome=material("Tarnished chrome",(.24,.28,.27),.8,.4)
black=material("Recesses",(.008,.013,.013),0,.9)
glass=material("Remaining dusty glass",(.055,.12,.13),.2,.32)
seat=material("Torn brown upholstery",(.13,.075,.045),0,.96)
red=material("Tail light",(.32,.025,.012),.1,.35)

def finish(obj, mat, bevel=0):
    obj.data.materials.append(mat)
    if bevel:
        mod=obj.modifiers.new("Manufactured edge radii","BEVEL")
        mod.width=bevel;mod.segments=3
        bpy.context.view_layer.objects.active=obj
        bpy.ops.object.modifier_apply(modifier=mod.name)
        mod=obj.modifiers.new("Weighted corner normals","WEIGHTED_NORMAL")
        bpy.ops.object.modifier_apply(modifier=mod.name)
    bpy.ops.object.select_all(action="DESELECT");obj.select_set(True)
    bpy.context.view_layer.objects.active=obj
    bpy.ops.object.mode_set(mode="EDIT");bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.cube_project(cube_size=1.4)
    bpy.ops.object.mode_set(mode="OBJECT")
    return obj

def box(name,p,s,mat,bevel=.03,rot=None):
    bpy.ops.mesh.primitive_cube_add(size=1,location=p)
    o=bpy.context.object;o.name=name;o.dimensions=s
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    finish(o,mat,bevel)
    if rot:o.rotation_euler=rot
    return o

def cylinder(name,p,r,depth,mat,axis='Z',vertices=20):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=depth,location=p)
    o=bpy.context.object;o.name=name
    if axis=='X':o.rotation_euler.y=math.pi/2
    if axis=='Y':o.rotation_euler.x=math.pi/2
    return finish(o,mat,.012)

def tube(name,points,r,mat):
    c=bpy.data.curves.new(name,"CURVE");c.dimensions="3D";c.resolution_u=12
    c.bevel_depth=r;c.bevel_resolution=2;c.resolution_u=8
    s=c.splines.new('BEZIER');s.bezier_points.add(len(points)-1)
    for b,p in zip(s.bezier_points,points):
        b.co=p;b.handle_left_type='AUTO';b.handle_right_type='AUTO'
    o=bpy.data.objects.new(name,c);bpy.context.collection.objects.link(o)
    bpy.ops.object.select_all(action="DESELECT");o.select_set(True);bpy.context.view_layer.objects.active=o
    bpy.ops.object.convert(target="MESH");finish(o,mat)
    return o

def mesh(name,verts,faces,mat,bevel=0):
    m=bpy.data.meshes.new(name);m.from_pydata(verts,[],faces);m.update()
    o=bpy.data.objects.new(name,m);bpy.context.collection.objects.link(o)
    return finish(o,mat,bevel)

def lettering(name,text,p,size,mat):
    c=bpy.data.curves.new(name,"FONT");c.body=text;c.size=size;c.align_x='CENTER'
    c.extrude=.001;c.resolution_u=3
    o=bpy.data.objects.new(name,c);bpy.context.collection.objects.link(o)
    o.location=p;o.rotation_euler=(math.pi/2,0,0);c.materials.append(mat)
    bpy.ops.object.select_all(action="DESELECT");o.select_set(True);bpy.context.view_layer.objects.active=o
    bpy.ops.object.convert(target="MESH")
    return o

def save_asset(name):
    # Combine by material: low draw-call count, preserve authored UVs and normals.
    groups={}
    for o in list(bpy.context.scene.objects):
        if o.type=='MESH':
            groups.setdefault(o.data.materials[0].name,[]).append(o)
    for mat,objects in groups.items():
        bpy.ops.object.select_all(action='DESELECT')
        for o in objects:o.select_set(True)
        bpy.context.view_layer.objects.active=objects[0]
        bpy.ops.object.join();bpy.context.object.name=mat
    bpy.ops.object.select_all(action="SELECT")
    (ROOT / "art_source").mkdir(exist_ok=True)
    bpy.ops.file.pack_all()
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT / "art_source" / f"{name}.blend"))
    bpy.ops.export_scene.gltf(filepath=str(OUT/f"{name}.glb"),export_format='GLB',
        use_selection=True,export_yup=True,export_apply=True,export_texcoords=True,
        export_normals=True,export_materials='EXPORT')
    triangles=sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in bpy.context.scene.objects if o.type=='MESH')
    print(f"ASSET {name}: {triangles} triangles; {len(groups)} material batches")

def pump():
    box("Cast plinth",(0,0,.10),(.95,.78,.20),rust,.06)
    box("Pressed enamel lower housing",(0,0,.91),(.76,.60,1.48),paint,.105)
    box("Ivory meter housing",(0,0,1.83),(.93,.72,.69),cream,.16)
    box("Meter bezel",(0,-.375,1.86),(.70,.045,.34),chrome,.045)
    box("Meter dark glass",(0,-.405,1.86),(.62,.02,.27),black,.025)
    lettering("Mechanical meter","087.4",(0,-.425,1.81),.14,cream)
    lettering("Meter units","LITRY",(0,-.426,1.69),.055,cream)
    box("Service panel",(0,-.312,.82),(.57,.025,.66),rust,.03)
    for i in range(6):box("Vent slot",(0,-.331,.66+i*.055),(.42,.018,.019),black,.006)
    for x in [-.24,.24]:
        for z in [.55,1.1]:cylinder("Panel screw",(x,-.339,z),.018,.018,chrome,'Y',8)
    cylinder("Round brand medallion",(0,0,2.33),.25,.13,cream,'Y',32)
    cylinder("Medallion inset",(0,-.075,2.33),.205,.025,paint,'Y',32)
    lettering("ATOM badge","ATOM",(0,-.095,2.28),.1,cream)
    tube("Flexible hanging hose",[(.42,0,1.95),(.72,.05,1.48),(.84,.04,.38),(.64,-.12,.27),(.56,-.20,1.32)],.038,rubber)
    box("Nozzle grip",(.56,-.20,1.37),(.10,.13,.30),chrome,.025,rot=(0,.25,0))
    tube("Nozzle spout",[(.60,-.20,1.51),(.63,-.20,1.64),(.47,-.20,1.73)],.026,chrome)
    tube("Trigger guard",[(.59,-.28,1.27),(.70,-.28,1.29),(.67,-.28,1.46),(.60,-.28,1.49)],.014,black)
    box("Chipped lower edge",(0,-.305,.30),(.65,.025,.075),rust,.015)
    save_asset("ashen_pump")

def car():
    # Continuous tapered body, with real wheel openings on separate side panels.
    box("Underbody",(0,0,.43),(1.85,4.65,.18),black,.08)
    sections=[(-2.55,.72,.66),(-2.25,1.04,.94),(-1.35,1.10,1.03),(.50,1.08,1.03),(1.65,1.03,.93),(2.45,.80,.74)]
    verts=[]
    for y,w,z in sections:verts += [(-w,y,z),(w,y,z),(-w*.92,y,.49),(w*.92,y,.49)]
    faces=[]
    for i in range(len(sections)-1):
        a=i*4;b=a+4
        faces += [(a,b,b+1,a+1),(a+2,a+3,b+3,b+2)]
    faces += [(0,1,3,2),(20,22,23,21)]
    mesh("Sculpted continuous body",verts,faces,rust,.055)
    # Side outlines follow wheel arches; no solid panels cover the tires.
    outline=[(-2.5,.58),(-2.5,.83),(-2.05,1.01),(-1.35,1.05),(.8,1.04),(1.95,.94),(2.45,.76),(2.45,.51),
             (2.12,.51),(2.05,.78),(1.85,1.00),(1.55,1.06),(1.25,.98),(1.05,.78),(.99,.50),
             (-.97,.50),(-1.03,.78),(-1.23,1.00),(-1.53,1.07),(-1.83,1.00),(-2.03,.78),(-2.09,.51)]
    for side in [-1,1]:
        v=[(side*1.055,y,z) for y,z in outline]+[(side*.97,y,z) for y,z in outline]
        n=len(outline);f=[tuple(range(n)),tuple(reversed(range(n,n*2)))]
        f += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
        mesh("Shaped fender with wheel cutouts",v,f,paint,.025)
        tube("Chrome belt line",[(side*1.07,-2.13,.96),(side*1.10,-.7,1.06),(side*1.10,.55,1.06),(side*1.02,2.07,.91)],.022,chrome)
    # Window openings are actual empty space; pillars support a curved roof.
    roof=[(-.79,-.99,1.73),(.79,-.99,1.73),(-.84,-.65,1.84),(.84,-.65,1.84),(-.80,.40,1.82),(.80,.40,1.82),(-.67,.68,1.68),(.67,.68,1.68)]
    mesh("Rounded coupe roof",roof,[(0,1,3,2),(2,3,5,4),(4,5,7,6)],paint,.035)
    for side in [-1,1]:
        for a,b in [((side*.96,-1.35,1.03),(side*.79,-.99,1.73)),((side*1.0,.98,1.03),(side*.67,.68,1.68))]:
            tube("Window pillars",[a,b],.058,rust)
        tube("Roof side trim",[(side*.79,-.99,1.73),(side*.84,-.65,1.84),(side*.8,.4,1.82),(side*.67,.68,1.68)],.027,chrome)
        box("Door handle",(side*1.10,-.55,1.0),(.05,.22,.055),chrome,.02)
    # A jagged remnant of windshield, leaving the rest visibly broken.
    mesh("Broken windshield remnant",[(-.92,.98,1.06),(.93,.98,1.06),(.75,.84,1.34),(.38,.92,1.20),(.22,.79,1.41),(-.20,.88,1.27),(-.64,.82,1.38)],
         [(0,1,2,3,4,5,6)],glass)
    box("Cabin floor",(0,-.1,.91),(1.7,2.0,.08),black)
    for x in [-.46,.46]:
        box("Seat cushion",(x,-.33,1.04),(.68,.68,.18),seat,.09)
        box("Seat back",(x,-.65,1.30),(.68,.18,.65),seat,.10,rot=(.12,0,0))
    box("Dashboard",(0,.65,1.15),(1.65,.32,.24),black,.08)
    # Raised hood and exposed engine block.
    box("Engine bay",(0,1.65,.96),(1.50,1.35,.08),black,.04)
    box("Engine block",(0,1.60,1.08),(.58,.75,.26),rust,.06)
    for x in [-.43,.43]:tube("Engine plumbing",[(x,1.34,1.06),(x,1.55,1.21),(x,1.97,1.08)],.055,chrome)
    box("Buckled raised hood",(0,1.69,1.34),(1.80,1.34,.055),paint,.04,rot=(-.40,.06,.04))
    # One missing wheel leaves an exposed hub; other tires have rounded shoulders.
    for side in [-1,1]:
        for y in [-1.53,1.55]:
            if side==-1 and y>0:
                cylinder("Exposed brake drum",(side*1.08,y,.51),.22,.13,rust,'X')
                continue
            bpy.ops.mesh.primitive_torus_add(major_radius=.35,minor_radius=.13,major_segments=28,minor_segments=10,location=(side*1.08,y,.51),rotation=(0,math.pi/2,0))
            finish(bpy.context.object,rubber);bpy.context.object.name="Rounded worn tire"
            cylinder("Wheel rim",(side*1.12,y,.51),.25,.19,chrome,'X')
            cylinder("Rust hub",(side*1.23,y,.51),.12,.025,rust,'X')
    for y in [-2.5,2.45]:
        box("Curved bumper",(0,y,.55),(1.89,.19,.16),chrome,.075)
    for x in [-.62,.62]:
        cylinder("Headlamp bezel",(x,2.40,.78),.17,.08,chrome,'Y',24)
        cylinder("Dead headlamp",(x,2.45,.78),.13,.02,cream,'Y',24)
        box("Tail light",(x,-2.52,.79),(.20,.05,.12),red,.025)
    for i in range(7):box("Front grille bar",(-.39+i*.13,2.47,.73),(.045,.04,.22),black,.008)
    save_asset("ashen_coupe_wreck")

pump()
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
car()
