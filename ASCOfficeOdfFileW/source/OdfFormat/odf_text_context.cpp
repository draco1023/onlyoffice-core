#include "precompiled_cpodf.h"
#include "logging.h"

#include <boost/foreach.hpp>
#include <iostream>

#include "odf_text_context.h"
#include "odf_style_context.h"
#include "odf_conversion_context.h"

#include "text_elements.h"
#include "paragraph_elements.h"

namespace cpdoccore {
namespace odf
{

odf_text_context::odf_text_context(odf_style_context * styles_context,odf_conversion_context *odf_context)
{
	styles_context_ = styles_context;
	odf_context_ = odf_context;

	last_paragraph_ = NULL;
}
odf_text_context::~odf_text_context()
{
}
void odf_text_context::set_styles_context(odf_style_context*  styles_context)
{
	styles_context_ = styles_context;
}

void odf_text_context::add_text_content(const std::wstring & text)
{
	if (current_level_.size() >=0 )
		current_level_.back()->add_text(text);
	else
	{
	}
}
void odf_text_context::start_paragraph(bool styled)
{
	office_element_ptr paragr_elm;
	create_element(L"text", L"p",paragr_elm,odf_context_);

	start_paragraph(paragr_elm, styled);

}
void odf_text_context::start_paragraph(office_element_ptr & elm, bool styled)
{
	int level = current_level_.size();

	std::wstring style_name;
	office_element_ptr style_elm;
	if (styled)
	{
		style_name = styles_context_->last_state().get_name();
		style_elm = styles_context_->last_state().get_office_element();
		
		text_p* p = dynamic_cast<text_p*>(elm.get());
		if (p)p->paragraph_.paragraph_attrs_.text_style_name_ = style_ref(style_name);	
	}

	odf_text_state state={elm,  style_name, style_elm,level};
	text_elements_list_.push_back(state);
	if (current_level_.size()>0)
		current_level_.back()->add_child_element(elm);

	current_level_.push_back(elm);
	
}

void odf_text_context::end_paragraph()
{
	current_level_.pop_back();
}

void odf_text_context::start_element(office_element_ptr & elm)
{
	int level = current_level_.size();

	odf_text_state state={elm, L"", office_element_ptr(), level};

	text_elements_list_.push_back(state);
	if (current_level_.size()>0)
		current_level_.back()->add_child_element(elm);

	current_level_.push_back(elm);
}
void odf_text_context::end_element()
{
	current_level_.pop_back();
}

void odf_text_context::start_span(bool styled)
{
	if (styles_context_ == NULL)return;

	office_element_ptr span_elm;
	create_element(L"text", L"span", span_elm, odf_context_);


	int level = current_level_.size();
	
	std::wstring style_name;
	office_element_ptr style_elm;
	if (styled)
	{
		style_name = styles_context_->last_state().get_name();
		style_elm = styles_context_->last_state().get_office_element();
		
		text_span* span = dynamic_cast<text_span*>(span_elm.get());
		if (span) span->text_style_name_ = style_ref(style_name);
	}

	odf_text_state state={	span_elm, style_name, style_elm, level};

	text_elements_list_.push_back(state);
	
	if (current_level_.size()>0)
		current_level_.back()->add_child_element(span_elm);

	current_level_.push_back(span_elm);
}

void odf_text_context::end_span()
{
	current_level_.pop_back();
}

}
}