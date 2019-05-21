:- module(class, [
  is_class/1,
  find_class_by_name/2,
  find_class/2,
  get_class_modifiers/2,
  get_class_name/2,
  get_class_package/2,
  get_class_parent/2,
  get_class_interfaces/2,
  get_class_attributes/2,
  get_class_methods/2,
  create_class/5,
  create_class/6
]).

:- use_module(graph, [edge/3, vertex/2, create_edge/3, create_vertex/2]).
:- use_module(common, [get_name/2, get_package/2, get_modifiers/2]).
:- use_module('../representation/qualified_name', [generate_qualified_name/2, qualified_name/3]).
:- use_module(interface, [is_interface/1]).
:- use_module(modifier, [is_modifier/1]).

% Assertion Theorems
is_class(Label) :-
  vertex(class, Label).

% Search Theorems
find_class_by_name(Name, Class) :-
  is_class(Class),
  edge(Class, name, Name).

find_class(Text, Text) :-
  atom(Text),
  is_class(Text).
find_class(Text, Class) :-
  string(Text),
  find_class_by_name(Text, Class).

% Property Theorems
get_class_modifiers(Class, Modifiers) :-
  is_class(Class),
  get_modifiers(Class, Modifiers).

get_class_name(Class, Name) :-
  is_class(Class),
  get_name(Class, Name).

get_class_package(Class, Package) :-
  is_class(Class),
  get_package(Class, Package).

get_class_parent(Class, Parent) :-
  is_class(Class),
  edge(Class, parent, Parent).

get_class_interfaces(Class, Interfaces) :-
  is_class(Class),
  findall(Interface, edge(Class, interface, Interface), Interfaces).

% Content Theorems
get_class_attributes(Text, Attributes) :-
  find_class(Text, Class),
  findall(Attribute, edge(Class, attribute, Attribute), Attributes).

get_class_methods(Text, Methods) :-
  find_class(Text, Class),
  findall(Method, edge(Class, method, Method), Methods).

%% Transformation Theorems
% Verification Theorems
class_exists(Package, Name) :-
  edge(Class, name, Name),
  edge(Class, package, Package),
  vertex(class, Class).

modifiers_are_valid([]).
modifiers_are_valid([Modifier|Rest]) :-
  is_modifier(Modifier),
  modifiers_are_valid(Rest).

interfaces_are_valid([]).
interfaces_are_valid([Interface|Rest]) :-
  is_interface(Interface),
  interfaces_are_valid(Rest).

can_create_class(Package, Modifiers, Name, Parent, Interfaces) :-
  \+ class_exists(Package, Name),
  modifiers_are_valid(Modifiers),
  is_class(Parent),
  interfaces_are_valid(Interfaces).

% Creation Theorems
create_class(Modifiers, Parent, Interfaces, QualifiedName, Class) :-
  qualified_name(QualifiedName, Package, Name),
  create_class(Package, Modifiers, Name, Parent, Interfaces, Class).
create_class(Package, Modifiers, Name, Parent, Interfaces, Class) :-
  can_create_class(Package, Modifiers, Name, Parent, Interfaces),
  generate_qualified_name([Package, Name], Class),
  create_vertex(class, Class),
  create_edge(Class, name, Name),
  create_edge(Class, package, Package).
