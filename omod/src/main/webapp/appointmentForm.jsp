<%@ include file="/WEB-INF/template/include.jsp"%>

<%@ include file="/WEB-INF/template/header.jsp"%>
<openmrs:htmlInclude file="/scripts/timepicker/timepicker.js" />
<openmrs:htmlInclude
	file="/moduleResources/appointmentscheduling/Scripts/jquery.dataTables.js" />
<openmrs:htmlInclude
	file="/moduleResources/appointmentscheduling/Scripts/jquery.maxlength.js" />
<openmrs:htmlInclude
	file="/moduleResources/appointmentscheduling/Scripts/queryParameters.js" />
<openmrs:htmlInclude
	file="/moduleResources/appointmentscheduling/Styles/createAppointmentStyle.css" />
<openmrs:htmlInclude
	file="/moduleResources/appointmentscheduling/Styles/appointment_jQueryDatatable.css" />
<openmrs:htmlInclude
	file="/moduleResources/appointmentscheduling/Styles/jQuerySmoothness/jquery-ui-1.9.2.custom.css" />
	
<openmrs:require privilege="Schedule Appointments" otherwise="/login.htm" redirect="/module/appointmentscheduling/appointmentForm.form" />

<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<script type="text/javascript">
	function forceMaxLength(object, maxLength) {
		if (object.value.length >= maxLength) {
			object.value = object.value.substring(0, maxLength);
		}
	}
</script>
<script type="text/javascript"
	src='${pageContext.request.contextPath}/dwr/engine.js'></script>
<script type="text/javascript"
	src='${pageContext.request.contextPath}/dwr/util.js'></script>
<script type="text/javascript"
	src='${pageContext.request.contextPath}/dwr/interface/DWRAppointmentService.js'></script>
<script type="text/javascript">
	$j(document)
			.ready(
					function() {
						//Prevent date keyboard input
						$j("#fromDate").keypress(function(event) {event.preventDefault();});
						$j("#toDate").keypress(function(event) {event.preventDefault();});
						
						//Focus "search patient"
						$j('#patient_id_selection').focus();
						
						//Init max notes length
						$j('[name="reason"]').maxlength({
							'feedback' : '.charsLeft',
						    'useInput' : true
						});
						
						//Datatables.net
						var oTable = $j('#availableTimesTable').dataTable(
								{
									"aoColumns" : [ {
										"bSortable" : true
									}, {
										"bSortable" : true
									}, {
										"bSortable" : true
									}, {
										"iDataSort" : 6
									}, {
										"bSortable" : true
									}, {
										"bSortable" : true
									}, {
										"bVisible" : false
									}, {
										"bVisible" : true
									} ],
									"oLanguage": {
 										"sZeroRecords": "<spring:message code='appointmentscheduling.Appointment.create.table.empty' />"
									},
									"aLengthMenu" : [ [10, 25, 50, -1 ],
											[10, 25, 50, "All" ] ],
									"iDisplayLength" : 10,
									"bLengthChange" : true,
									"bFilter" : false,
									"bInfo" : true,
									"bPaginate" : true,
									"bJQueryUI" : true,
									"sDom" : "<'fg-toolbar ui-toolbar ui-widget-header ui-corner-tl ui-corner-tr ui-helper-clearfix' <'addons'>fl>t<'fg-toolbar ui-toolbar ui-widget-header ui-corner-bl ui-corner-br ui-helper-clearfix'<'statusDiv'>ip>",
									"fnDrawCallback" : function() {
												//Clear and prepend the schedule appointment button and cancelled checkbox
												$j(".addons").html("");
												$j(".addons")
														.prepend(
																"<table style='margin:10px; float:right; display:inline-block;' >"+
																	"<tr><td><openmrs:hasPrivilege privilege='Squeezing Appointments'>"+
																		"<input type=\"checkbox\" name=\"includeFull\" value=\"true\" onchange='this.form.submit();' ${(param.includeFull=='true') ? 'checked' : ''}>"+
																			"<spring:message code='appointmentscheduling.Appointment.create.label.showFull' />"+
																			"<br/><c:if test='${param.includeFull==\'true\'}'>'"+
																			"<div id='slotIndex'> <img src='${pageContext.request.contextPath}/moduleResources/appointmentscheduling/Images/index_fullTimeslot.png' alt='<spring:message code='appointmentscheduling.Appointment.create.lbl.fullSlot'/>'/>"+
																			" = <spring:message code='appointmentscheduling.Appointment.create.lbl.fullSlot'/></div></c:if>"+
																	"</openmrs:hasPrivilege></td></tr>"+
																"</table>");
									}
								});

						//Default sort: ascending by date
						oTable.fnSort([[3,'asc']]);	
								
						//Used to delete the "ghost" row that is used in order to prevent the first row
						//being unselected on post-request bug.
						if(document.getElementById('BugfixRow'))
							oTable.fnDeleteRow(document.getElementById('BugfixRow'));		
								
						//If the user is using "Simple" version
						if ($j('#locationId').length > 0) {
							var selectLocation = $j('#locationId');
							//Set the Null option text (Default is empty string)
							if (selectLocation[0][0].innerHTML == '')
								selectLocation[0][0].innerHTML = "<spring:message code='appointmentscheduling.Appointment.create.label.locationNotSpecified'/>";

						}

						//Toggle Checked Row
						$j('.dataTables_wrapper tbody tr').live(
								'click',
								function() {
									if($j(this).hasClass('notSelectedFullRow')){
										if(!confirm("<spring:message code='appointmentscheduling.Appointment.create.prompt.fullSlot'/> " + $j("td:eq(6)",this)[0].innerHTML))
											return;
									}
									var table = $j('#availableTimesTable')
											.dataTable();
									var nNodes = table.fnGetNodes();
									for ( var i = 0; i < nNodes.length; i++) {
										$j('input:radio', nNodes[i]).attr(
												'checked', false);
										if($j(nNodes[i]).hasClass('selectedFullRow')){
											$j(nNodes[i])
													.removeClass('selectedFullRow');
											$j(nNodes[i])
													.addClass('notSelectedFullRow');
										}
										else{
											$j(nNodes[i])
													.removeClass('selectedRow');
											$j(nNodes[i])
													.addClass('notSelectedRow');
										}
									}
									$j('input:radio', this).attr('checked',
											true);
									if($j(this).hasClass('notSelectedFullRow')){
										$j(this).addClass('selectedFullRow');
										$j(this).removeClass('notSelectedFullRow');
									}
									else{
										$j(this).addClass('selectedRow');
										$j(this).removeClass('notSelectedRow');
									}
								});
					});
function addQueryParameter(paramName){
	var value = queryParameters[paramName];
	var currentURL = window.location.href;
	
		
}


	function updatePatient(formFieldId, patientObj, isPageLoad) {
		if (patientObj != null) {
			if(queryParameters['patientId']!=patientObj.patientId){
				queryParameters['patientId']=patientObj.patientId;
				location.search = $j.param(queryParameters);
				return;

			}
			addPatientLink(patientObj);
			DWRAppointmentService
					.getPatientDescription(
							patientObj.patientId,
							function(details) {
								if (!details) {
									document.getElementById('patientDataCell').innerHTML = "";
									return;
								}
								var phone = "<spring:message code='appointmentscheduling.Appointment.create.patientNoPhoneNumber'/>";
								var dateMissedLastAppointment = null;
								if (details.phoneNumber)
									phone = details.phoneNumber;
								if (details.dateMissedLastAppointment)
									dateMissedLastAppointment = details.dateMissedLastAppointment;
								var detailsText = "<b><spring:message code='appointmentscheduling.Appointment.create.patientPhoneNumber'/></b>"
										+ phone;
								if(dateMissedLastAppointment){
									detailsText += "<br/><spring:message code='appointmentscheduling.Appointment.create.patientMissedMeeting'/><div style='color:red; display:inline-block;'><b>"+dateMissedLastAppointment+"</b></div>";
								}
								detailsText += "<br/><br/>";
								for ( var i = 0; i < details.identifiers.length; i++) {
									var array = details.identifiers[i]
											.split(":");
									detailsText += "<b>" + array[0] + "</b>: "
											+ array[1] + "<br/>";
								}

								document.getElementById('patientDataCell').innerHTML = detailsText;
							});
		}
	}
	function addPatientLink(patientObj) {
		document.getElementById('patientLinkDiv').innerHTML = "";
		if (patientObj != null) {
			var genderImg = "<img src='${pageContext.request.contextPath}/images/male.gif' alt='<spring:message code='Person.gender.male'/>'/>";
			if (patientObj.gender != 'M')
				genderImg = "<img src='${pageContext.request.contextPath}/images/female.gif' alt='<spring:message code='Person.gender.female'/>'/>";
			var age = "";
			if (patientObj.age == 0)
				age += "1";
			else
				age += patientObj.age.toString();
			age += " <spring:message code='Person.age.year' />";
			var detailsText = "<table><tr><td>";
			detailsText += genderImg + " (" + age + ")<br/></td><td>";
			var message = "<img src='${pageContext.request.contextPath}/moduleResources/appointmentscheduling/Images/view.png' class='formIcon' alt=''/><spring:message code='appointmentscheduling.Appointment.create.link.viewPatient'/>";
			var link = "<a href='${pageContext.request.contextPath}/patientDashboard.form?patientId="
					+ patientObj.patientId + "'>";
			detailsText += link + message + "</a><br/>";
			message = "<img src='${pageContext.request.contextPath}/moduleResources/appointmentscheduling/Images/edit.png' class='formIcon' alt=''/><spring:message code='appointmentscheduling.Appointment.create.link.editPatient'/>";
			link = "<a href='${pageContext.request.contextPath}/admin/patients/shortPatientForm.form?patientId="
					+ patientObj.patientId + "'>";
			detailsText += link + message + "</a>";
			document.getElementById('patientLinkDiv').innerHTML += detailsText
					+ "</td></tr></table>";
		}
	}

	function updateToDate(object) {
		if (object.value == '') {
			var fromDate = document.getElementById('fromDate').value;
			if (fromDate != '')
				object.value = fromDate;
		}
		showDateTimePicker(object);
	}
</script>

<h2 id="headline">
	<c:if test="${param.flow!='walkin'}">
		<spring:message code="appointmentscheduling.Appointment.create.titleSchedule" />
	</c:if>
	<c:if test="${param.flow=='walkin'}">
		<spring:message code="appointmentscheduling.Appointment.create.titleWalkIn" />
	</c:if>
</h2>
<spring:hasBindErrors name="appointment">
	<spring:message code="fix.error" />
	<br />
</spring:hasBindErrors>
<form:form modelAttribute="appointment" method="post">
	<fieldset>
		<table id="createAppointmentTable">
			<tr class="boxHeader steps">
				<td colspan="3"><spring:message
						code="appointmentscheduling.Appointment.steps.selectPatient" /></td>
			</tr>
			<tr>
				<td class="formLabel"><spring:message
						code="appointmentscheduling.Appointment.create.label.findPatient" /></td>

				<td><spring:bind path="appointment.patient">
						<openmrs_tag:patientField formFieldName="patient"
							callback="updatePatient" initialValue="${status.value}"/>
						<c:if test="${status.errorMessage != ''}">
							<span class="error">${status.errorMessage}</span>
						</c:if>
					</spring:bind><div id="patientLinkDiv"></div></td>
				<td></td>
			</tr>
			<tr>
				<td></td>
				<td colspan="3" id="patientDataCell" style="font-style: italic;">
				</td>
			</tr>
			<tr class="boxHeader steps">
				<td colspan="3"><spring:message
						code="appointmentscheduling.Appointment.steps.defineAppointmentProperties" /></td>
			</tr>
			<tr>
				<td class="formLabel"><spring:message
						code="appointmentscheduling.Appointment.create.label.appointmentType" /></td>
				<td><spring:bind path="appointment.appointmentType">
						<select name="${status.expression}" id="appointmentTypeSelect">
							<c:forEach var="appointmentType" items="${appointmentTypeList}">
								<option value="${appointmentType.appointmentTypeId}"
									${appointment.appointmentType.appointmentTypeId==appointmentType.appointmentTypeId ? 'selected' : ''}>${appointmentType.name}</option>
							</c:forEach>
						</select>
						<c:if test="${status.errorMessage != ''}">
							<span class="error">${status.errorMessage}</span>
						</c:if>
					</spring:bind></td>
			</tr>
			<tr>
				<td class="formLabel"><spring:message
						code="appointmentscheduling.Appointment.create.label.location" /></td>
				<td><openmrs_tag:locationField formFieldName="locationId"
						initialValue="${selectedLocation}" optionHeader="[blank]" /></td>
			</tr>
			<tr>
				<td class="formLabel"><spring:message
						code="appointmentscheduling.Appointment.create.label.clinician" /></td>
				<td><select name="providerSelect" id="providerSelect">
						<option value="" ${null==param.providerSelect ? 'selected' : ''}>
							<spring:message
								code="appointmentscheduling.Appointment.create.label.clinicianNotSpecified" />
						</option>
						<c:forEach var="provider" items="${providerList}">
							<option value="${provider.providerId}"
								${provider.providerId==param.providerSelect ? 'selected' : ''}>${provider.name}</option>
						</c:forEach>
				</select></td>
			</tr>
			<c:if test="${param.flow!='walkin'}">
				<tr>
					<td class="formLabel"><spring:message
							code="appointmentscheduling.Appointment.create.label.betweenDates" /></td>
					<td><input type="text" name="fromDate" id="fromDate" size="16"
						value="${param.fromDate}" onfocus="showDateTimePicker(this)" /> <img
						src="${pageContext.request.contextPath}/moduleResources/appointmentscheduling/Images/calendarIcon.png"
						class="calendarIcon" alt=""
						onClick="document.getElementById('fromDate').focus();" /> and <input
						type="text" name="toDate" id="toDate" size="16"
						value="${param.toDate}" onfocus="updateToDate(this)" /> <img
						src="${pageContext.request.contextPath}/moduleResources/appointmentscheduling/Images/calendarIcon.png"
						class="calendarIcon" alt=""
						onClick="document.getElementById('toDate').focus();" /></td>
				</tr>
			</c:if>
			<tr class="boxHeader steps">
				<td colspan="3"><spring:message
						code="appointmentscheduling.Appointment.steps.selectTime" /></td>
			</tr>
			<tr>
				<td />
				<td><input type="submit" name="findAvailableTime"
					class="appointmentButton"
					value="<spring:message code="appointmentscheduling.Appointment.create.findTime"/>"></td>
				<td><spring:bind path="appointment.timeSlot">
						<c:if test="${status.errorMessage != ''}">
							<span class="error">${status.errorMessage}</span>
						</c:if>
					</spring:bind></td>
			</tr>
			<tr>
				<td colspan="3">
					<table id="availableTimesTable" cellspacing="0">
						<thead>
							<tr>
								<th style="display:none;"><spring:message
										code="appointmentscheduling.Appointment.create.header.selectedOption" /></th>
								<th><spring:message
										code="appointmentscheduling.Appointment.create.header.clinician" /></th>
								<th><spring:message
										code="appointmentscheduling.Appointment.create.header.appointmentType" /></th>
								<th><spring:message
										code="appointmentscheduling.Appointment.create.header.date" /></th>
								<th><spring:message
										code="appointmentscheduling.Appointment.create.header.timeSlot" /></th>
								<th><spring:message
										code="appointmentscheduling.Appointment.create.header.location" /></th>
								<th>Hidden Sortable Date</th>
								<th style="display:none;">Hidden Sortable Timeleft</th>
							</tr>
						</thead>
						<tbody>
							<c:if test="${fn:length(availableTimes)>0}" >
								<tr style="display:none;" id="BugfixRow"><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>						
							</c:if>
							<c:forEach var="slot" items="${availableTimes}">
								<tr
									${slot.timeSlotId==appointment.timeSlot.timeSlotId ? 'class="selectedRow"' : 'class="notSelectedRow"'} />
								<td style="display:none;"><spring:bind path="appointment.timeSlot">
										<input type="radio" name="${status.expression}"
											value="${slot.timeSlotId}"
											${slot.timeSlotId==appointment.timeSlot.timeSlotId ? 'checked' : ''} />
									</spring:bind></td>

								<td>${slot.appointmentBlock.provider.name}</td>
								<td><c:forEach var="appointmentType"
										items="${slot.appointmentBlock.types}" varStatus="status">
                                                                ${appointmentType.name}<c:if
											test="${status.index != fn:length(slot.appointmentBlock.types)-1}">, </c:if>
									</c:forEach></td>
								<td><fmt:formatDate type="date" value="${slot.startDate}" /></td>
								<td><fmt:formatDate type="time" pattern="HH:mm"
										value="${slot.startDate}" /> - <fmt:formatDate type="time"
										pattern="HH:mm" value="${slot.endDate}" /></td>
								<td>${slot.appointmentBlock.location.name}</td>
								<td><fmt:formatDate type="date" value="${slot.startDate}"
										pattern="yyyyMMddHHmm" /></td>
								<td style="display:none;"></td>
								</tr>
							</c:forEach>
							<c:forEach var="slot" items="${fullSlots}">
								<tr
									${slot.timeSlotId==appointment.timeSlot.timeSlotId ? 'class="selectedFullRow"' : 'class="notSelectedFullRow"'} />
								<td style="display:none;"><spring:bind path="appointment.timeSlot">
										<input type="radio" name="${status.expression}"
											value="${slot.timeSlotId}"
											${slot.timeSlotId==appointment.timeSlot.timeSlotId ? 'checked' : ''} />
									</spring:bind></td>

								<td>${slot.appointmentBlock.provider.name}</td>
								<td><c:forEach var="appointmentType"
										items="${slot.appointmentBlock.types}" varStatus="status">
                                                                ${appointmentType.name}<c:if
											test="${status.index != fn:length(slot.appointmentBlock.types)-1}">, </c:if>
									</c:forEach></td>
								<td><fmt:formatDate type="date" value="${slot.startDate}" /></td>
								<td><fmt:formatDate type="time" pattern="HH:mm"
										value="${slot.startDate}" /> - <fmt:formatDate type="time"
										pattern="HH:mm" value="${slot.endDate}" /></td>
								<td>${slot.appointmentBlock.location.name}</td>
								<td><fmt:formatDate type="date" value="${slot.startDate}"
										pattern="yyyyMMddHHmm" /></td>
								<td style="display:none;">${overdueTimes[slot.timeSlotId]}</td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
				</td>
			</tr>
			<tr class="boxHeader steps">
				<td colspan="3"><spring:message
						code="appointmentscheduling.Appointment.steps.enterNotes" /></td>
			</tr>
			<tr>
				<td class="formLabel"><spring:message
						code="appointmentscheduling.Appointment.create.label.reason" /></td>
				<spring:bind path="appointment.reason">
					<td><textarea name="reason" rows="3" cols="50"
							style="resize: none"
							onkeypress="return forceMaxLength(this, 1024);">${status.value}</textarea></td>
				</spring:bind>
				<input type="hidden" name="maxlength" value="1024" />
			</tr>
			<tr><td></td><td style="font-size:12px;">
				(<spring:message code="appointmentscheduling.Appointment.create.label.charactersLeft" /><span class="charsLeft">1024</span>)
			</td></tr>
			<tr>
				<td></td>
				<td><input type="submit" class="saveButton"
					value="<spring:message code="appointmentscheduling.Appointment.create.save"/>"
					name="save"></td>
			</tr>
		</table>
	</fieldset>
</form:form>
<%@ include file="/WEB-INF/template/footer.jsp"%>