using ClinicaAPI.DTOs;

namespace ClinicaAPI.Services.Interfaces;

public interface IPacienteService
{
    IEnumerable<PacienteResponseDto> ObtenerTodos();
    PacienteResponseDto ObtenerPorId(int id);
    PacienteResponseDto Crear(PacienteCreateDto dto);
    PacienteResponseDto Actualizar(int id, PacienteUpdateDto dto);
    void Eliminar(int id);
}
